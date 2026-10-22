Your days spent slogging through a spaghetti of scripts are over.
Use JavaScript or Python when you need flexibility and UI for everything else.

## What is n8n?
n8n allows you to build flexible workflows focused on deep data integration. And with sharable templates and a user-friendly UI, the less technical people on your team can collaborate on them too. Unlike other tools, complexity is not a limitation. So you can build whatever you want — without stressing over budget.

## Common use cases
Pump data around your entire tech stack with 350+ native integrations. (Or use custom code to create your own.) From Support, to DevOps, all the way to Sales.

## Boost efficiency
Forget error-prone tasks like setting up servers and monitoring APIs for your less tech savvy teams. n8n automates the frustrating work for you. So you can focus your energy on tasks that move the needle. And even your entry-level engineers and interns can become more productive.


## Single sign-on (Enterprise license)

Turn on "Single sign-on with Emporium" and set the Enterprise license key to sign in through the Emporium login. With it off, n8n uses local email accounts and its SSO settings are managed by this chart.

Recovery if password login stops working for non-owner users after the license expired while OIDC was the login method (n8n keeps `userManagement.authenticationMethod = oidc` and rejects password logins):

1. Preferred: set a valid license key, then turn single sign-on off.
2. Without a license: set the stored method back to `email` and restart n8n. The setting is the row with key `userManagement.authenticationMethod` in the `settings` table (SQLite file `/home/node/.n8n/database.sqlite`, or the PostgreSQL database when enabled):

   ```sql
   UPDATE settings SET value = 'email' WHERE key = 'userManagement.authenticationMethod';
   ```
