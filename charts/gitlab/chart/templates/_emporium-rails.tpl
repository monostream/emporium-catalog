{{/*
Rails initializer that maps Emporium's Logto admin role to GitLab's admin flag
and links OpenID Connect sign-ins to existing accounts by email only when the
email is verified.
GitLab CE ignores the OIDC admin_groups option (it is a Premium feature), so
this does the same for the "roles" claim. Takes a context with .Values.global,
so the parent chart (ConfigMap) and the webservice subchart (checksum in
extraVolumes) render the same content.
*/}}
{{- define "gitlab.emporium.adminSyncInitializer" -}}
{{- $adminRole := dig "emporium" "adminRole" "" .Values.global -}}
{{- if not (regexMatch "^[A-Za-z0-9_.:-]+$" $adminRole) -}}
{{- fail "global.emporium.adminRole may only contain letters, digits, '_', '.', ':' and '-'" -}}
{{- end -}}
# frozen_string_literal: true

# Installed by the Emporium GitLab chart. Whenever a user signs in with OpenID
# Connect, users with the Logto role {{ $adminRole }} become GitLab
# administrators and everybody else loses administrator rights. The roles come
# from the "roles" claim of Logto's userinfo response (scope "roles"). Users
# who sign in otherwise (e.g. root with a password) are not touched.
#
# Like GitLab's own admin_groups (EE Gitlab::Auth::Oidc::User#find_user), the
# flag is set while the OmniAuth callback looks up the user, and saved with the
# user by Gitlab::Auth::OAuth::User#find_and_update!. That happens before GitLab
# asks for a second factor, so the sync does not depend on the request that
# completes the sign-in (with local two-factor authentication that is a later
# request without the OmniAuth data).
module EmporiumAdminSync
  PROVIDER = 'openid_connect'
  ADMIN_ROLE = '{{ $adminRole }}'

  # true or false, or nil when the userinfo response has no roles claim
  def self.admin_role?(omniauth_hash)
    info = (omniauth_hash.dig('extra', 'raw_info') || {}).to_h.transform_keys(&:to_s)
    return unless info.key?('roles')

    Array(info['roles']).map(&:to_s).include?(ADMIN_ROLE)
  end

  # Sets the admin flag of a found or newly built user; the caller saves it.
  def self.apply(user, auth_hash)
    return unless user.is_a?(::User) && auth_hash.provider.to_s == PROVIDER

    admin = admin_role?(auth_hash.auth_hash)
    if admin.nil?
      Gitlab::AppLogger.warn(message: 'Emporium admin sync: no roles claim, admin flag unchanged', user_id: user.id)
      return
    end
    return if user.admin? == admin

    user.admin = admin
    Gitlab::AppLogger.info(message: 'Emporium admin sync: changing admin flag', user_id: user.id, username: user.username, admin: admin)
  rescue StandardError => e
    Gitlab::AppLogger.error(message: 'Emporium admin sync failed', user_id: user&.id, error: e.message)
  end

  # true only when the userinfo response says the email is verified (Logto
  # sends a boolean; accept the string form too)
  def self.email_verified?(omniauth_hash)
    info = (omniauth_hash.dig('extra', 'raw_info') || {}).to_h.transform_keys(&:to_s)
    [true, 'true'].include?(info['email_verified'])
  end

  # Prepended to Gitlab::Auth::OAuth::User (and so its subclasses, e.g. the
  # EE Gitlab::Auth::Oidc::User, which call super)
  module OAuthUser
    def find_user
      user = super
      EmporiumAdminSync.apply(user, auth_hash) if user
      user
    end

    protected

    # GitLab links an OpenID Connect sign-in to an existing local account with
    # the same email (auto_link_user) without looking at email_verified. Only
    # link when the identity provider vouches for the email; otherwise the
    # sign-in does not take over the account (GitLab then refuses to create a
    # second user with that email). Users already linked by their OIDC subject
    # are found before this and are not affected.
    def find_by_email
      if auth_hash.provider.to_s == PROVIDER && !EmporiumAdminSync.email_verified?(auth_hash.auth_hash)
        Gitlab::AppLogger.warn(message: 'Emporium: not linking OIDC sign-in to an existing account by email, email_verified is not true')
        return
      end

      super
    end
  end
end

Rails.application.config.to_prepare do
  unless Gitlab::Auth::OAuth::User.ancestors.include?(EmporiumAdminSync::OAuthUser)
    Gitlab::Auth::OAuth::User.prepend(EmporiumAdminSync::OAuthUser)
  end
end
{{- end }}

{{/*
Short checksum of the initializer. The webservice pods name their volume after
it, so changing the initializer (or the admin role) rolls them; Rails only
reads initializers on boot.
*/}}
{{- define "gitlab.emporium.adminSyncChecksum" -}}
{{- include "gitlab.emporium.adminSyncInitializer" . | sha256sum | trunc 12 -}}
{{- end }}
