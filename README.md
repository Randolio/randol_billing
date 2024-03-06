# Randolio: Billing

Society fund support for renewed/qb-management/qb-banking by default. Look at the config or change the addSocietyFunds(job, amount, reason) function in the server file.

![Billing Menu](https://i.imgur.com/sqBwJeC.png)
![Global Target](https://i.imgur.com/CbgkFwU.png)
![Global Target Input](https://i.imgur.com/ElK5yfQ.png)

Player commission for billing also optionally supported with a percent cut defined per job in the config.

Recently added a global player option which will add/remove on job changes. See useGlobal in the config for each job to allow usage of it.

Requirements are ox_lib, ox_target/qb-target.

**Note**: If you get an error for nil value (global GetActivePlayers), make sure your ox lib is up to date and contains the GetActivePlayers() function in the init.lua.

# Showcase

https://streamable.com/hsb88l
