# Notes after installation:

You might to want to assign admin rights to some users.

## Login as Admin
The inital password is stored in the secret $instanceName-gitlab-initial-root-password in the namespace you've installed gitlab.

```bash
export NAMESPACE=littlelab
export NAME=littlelab
kubectl get secret -n $NAMESPACE $NAME-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 --decode; echo
```

Then you must sign in on the ``/users/sign_in?auto_sign_in=false`` endpoint on your instance to bypass the automatic sign-in that is configured.

After that you assign yourself admin rights in GitLab, change Admin password or do whatever you like as admin.