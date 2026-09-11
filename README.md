Ubuntu XFCE + XRDP on Railway

This project runs a lightweight Ubuntu 22.04 desktop with XFCE and XRDP inside a Docker container.

You can deploy it to Railway and connect to the Ubuntu desktop from a Windows 10 computer using the built-in Remote Desktop Connection (mstsc).

Important: This project requires Railway TCP Proxy for RDP. A normal Railway HTTP/HTTPS public domain will NOT work for RDP.

1. What You Will Get

After completing this guide, the setup will look like this:

Windows 10 PC
     |
     | Remote Desktop (RDP)
     |
     v
Railway TCP Proxy
     |
     | TCP
     |
     v
Ubuntu Docker Container
     |
     +-- XRDP : 3389
     |
     +-- XFCE Desktop
     |
     v
Ubuntu Desktop


You will be able to see an Ubuntu XFCE desktop window on your Windows 10 computer.

2. Project Files

Your GitHub repository should contain exactly these files:

ubuntu-rdp/
│
├── Dockerfile
├── start.sh
└── README.md


You do NOT need to manually install Ubuntu, XFCE, or XRDP on your computer.

Docker installs everything inside the Railway container.

3. What You Need

Before starting, you need:

A GitHub account
A Railway account
A Windows 10 computer with Remote Desktop Connection
An internet connection

You do not need to install Ubuntu on your Windows computer.

4. Create the GitHub Repository

Go to GitHub and create a new repository.

Give it a name such as:

ubuntu-rdp


You can make the repository public or private.

Recommended

Use a private repository if you don't want other people to see your project files.

Do NOT put your real RDP password inside the Dockerfile or README.

5. Upload the Project Files

Your repository needs:

Dockerfile
start.sh
README.md


The Dockerfile tells Railway how to build Ubuntu.

The start.sh starts XRDP when the container starts.

The README.md contains these instructions.

6. IMPORTANT: How the RDP Password Works

The RDP username is:

railwayuser


The password is NOT permanently stored in the Dockerfile.

Instead, Railway will provide the password to the container through an environment variable.

The variable is called:

RDP_PASSWORD


For example:

RDP_PASSWORD=MyVeryStrongPassword123!


You should choose your own strong password.

7. Choose Your RDP Password

For example, you could use something like:

RDP_PASSWORD=BlueTiger_9274!Moon


That is only an example.

Do not use that exact password.

Create your own strong password.

A good password should contain:

Uppercase letters
Lowercase letters
Numbers
Special characters
At least 12 characters

For example, your password could look like:

RDP_PASSWORD=MyUbuntu!Desktop_7284


Again, create your own password.

8. Create the Railway Project

Open Railway.

Create a new project.

Choose the option to deploy a project/repository from GitHub.

Select your GitHub repository:

ubuntu-rdp


Railway will see the Dockerfile automatically.

You normally do NOT need to manually select Ubuntu or Docker.

Railway will build the Docker image using the Dockerfile.

9. Wait for the Build

After you deploy the repository, Railway will start building the container.

The first build can take several minutes because XFCE and XRDP need to be installed.

You should see build activity in the Railway dashboard.

Wait until the deployment finishes successfully.

10. Set the RDP Password in Railway

This is one of the most important steps.

Open your Railway project.

Select your service.

Find:

Variables


or the environment variables section.

Create a new variable.

Set the variable name to:

RDP_PASSWORD


Set the value to your chosen password.

For example:

RDP_PASSWORD=MyUbuntu!Desktop_7284


The important part is:

Name:
RDP_PASSWORD

Value:
MyUbuntu!Desktop_7284


Do NOT put:

RDP_PASSWORD=RDP_PASSWORD=MyUbuntu...


There should only be one variable name and one value.

11. Save the Railway Variable

After adding the variable, save/apply the change.

Railway may automatically redeploy the service.

If it asks you to redeploy, allow it to redeploy.

The container needs to restart so that it receives the new password.

12. RDP Username

The username is always:

railwayuser


The username is created automatically by the Dockerfile.

You do not need to create it manually in Railway.

13. RDP Internal Port

XRDP listens inside the container on:

3389


The Dockerfile contains:

EXPOSE 3389


This tells Railway that the application uses port 3389.

However:

EXPOSE 3389 alone does NOT make RDP accessible from the internet.

You still need Railway TCP Proxy.

14. Configure Railway TCP Proxy

This is the step that allows Windows Remote Desktop to reach XRDP.

Open your Railway service.

Go to:

Settings


Then find the networking section.

Look for:

TCP Proxy


Create a TCP Proxy.

Set the destination/internal port to:

3389


Save/create the TCP proxy.

15. Find Your TCP Proxy Address

After creating the TCP Proxy, Railway will provide a public TCP address.

It will look approximately like:

something.proxy.rlwy.net:12345


The exact hostname and port will be different for your project.

For example:

ubuntu-rdp.proxy.rlwy.net:18472


The example above is NOT a real address.

Use the exact address Railway gives you.

You need BOTH:

Hostname


and

Port


For example:

Hostname:
ubuntu-rdp.proxy.rlwy.net

Port:
18472

16. Do NOT Use the Railway HTTP Domain

Railway may also provide an HTTP/HTTPS domain.

It can look something like:

https://your-project.up.railway.app


Do NOT put that address into Windows Remote Desktop.

That is an HTTP/HTTPS address.

RDP requires the Railway TCP Proxy.

You want something like:

something.proxy.rlwy.net:12345

17. Check Railway Logs

Before trying Windows Remote Desktop, open the Railway deployment logs.

You should see messages similar to:

Ubuntu XFCE + XRDP
User: railwayuser
Setting RDP password...
Starting XRDP session manager...
Starting XRDP server on port 3389...


The exact log formatting may differ.

The important thing is that XRDP starts successfully.

18. Connect From Windows 10

On your Windows 10 computer, press:

Windows Key + R


A small Run window will appear.

Type:

mstsc


Press:

Enter


This opens:

Remote Desktop Connection

19. Enter the Railway TCP Address

In the Remote Desktop Connection window, find:

Computer:


Enter the Railway TCP Proxy address.

For example:

something.proxy.rlwy.net:12345


Use the actual hostname and port provided by Railway.

Then click:

Connect

20. Enter the Username

When Windows asks for credentials, enter:

railwayuser


For the password, enter the password you created in Railway.

For example, if you created:

RDP_PASSWORD=MyUbuntu!Desktop_7284


then enter:

Username:
railwayuser

Password:
MyUbuntu!Desktop_7284

21. First Connection

Windows may show a security warning because the RDP server certificate is not trusted by your Windows computer.

This can happen with XRDP.

If you are sure you are connecting to your own Railway server, verify that the hostname is the one Railway provided.

Then continue the connection.

22. What You Should See

If everything is working correctly, Windows Remote Desktop should open an Ubuntu XFCE desktop.

You should see a lightweight Linux desktop environment.

The desktop is running inside the Railway container.

You can open applications such as:

Terminal
File Manager
Web Browser
Text Editor


depending on which XFCE packages are installed.

23. Very Important: Railway Is Not the Same as a Normal VPS

This project runs Ubuntu inside a Railway container.

It is NOT the same as renting a traditional Ubuntu VPS.

Containers can be restarted, redeployed, or replaced.

Therefore:

Do not assume files saved inside the container will permanently remain there.

If you need permanent data, you need to configure appropriate persistent storage.

24. Changing the RDP Password

You do not need to modify the Dockerfile.

Go to Railway:

Your Project
    ↓
Your Service
    ↓
Variables
    ↓
RDP_PASSWORD


Change the value.

For example:

Old:
RDP_PASSWORD=OldPassword

New:
RDP_PASSWORD=NewStrongPassword!927


Save the variable.

Restart/redeploy the service if Railway does not automatically restart it.

After the container restarts, use the new password.

25. Changing the Username

The current username is:

railwayuser


If you want to change it, you must modify the Dockerfile and start.sh.

For a beginner, I recommend leaving the username as:

railwayuser


and only changing the password through Railway Variables.

26. If RDP Says "Can't Connect"

Check these things in order.

Check 1 — Is Railway running?

Open the Railway project and make sure the service is deployed successfully.

Check 2 — Check the logs

Look for:

Starting XRDP server on port 3389...


If XRDP did not start, RDP will not work.

Check 3 — Check TCP Proxy

Make sure Railway TCP Proxy points to:

3389

Check 4 — Check the Windows address

Make sure you are using:

something.proxy.rlwy.net:PORT


not:

https://something.up.railway.app

Check 5 — Check the port

The TCP Proxy port is usually NOT 3389 on the public side.

For example, Railway might give:

something.proxy.rlwy.net:18472


Use:

something.proxy.rlwy.net:18472


not:

something.proxy.rlwy.net:3389

27. If Login Fails

Make sure the username is exactly:

railwayuser


Then check the Railway variable.

It should be:

RDP_PASSWORD


not:

PASSWORD


not:

RDP_PASS


The name must be:

RDP_PASSWORD


Also make sure you restarted/redeployed the container after changing the variable.

28. If You Get a Black Screen

If RDP connects but you see a black screen or immediately get disconnected:

Check Railway logs.
Make sure XFCE was installed successfully.
Make sure /home/railwayuser/.xsession contains:
startxfce4

Make sure the container successfully starts xrdp-sesman.
Restart/redeploy the Railway service.
29. If the Password Is Not Working

Remember that the password comes from:

RDP_PASSWORD


in Railway Variables.

For example:

RDP_PASSWORD=MyUbuntu!Desktop_7284


The login should be:

Username: railwayuser
Password: MyUbuntu!Desktop_7284


Do not include:

RDP_PASSWORD=


when entering the password into Windows.

Only enter the actual password.

30. Security Warning

A public RDP server can be discovered by automated internet scanners.

Do NOT use an easy password such as:

123456


or:

password


or:

RailwayPassword123


Use a strong random password.

Also remember that anyone who gets the RDP credentials may be able to access the Ubuntu desktop.

31. Never Put Your Real Password in GitHub

Do NOT change the Dockerfile to:

echo "railwayuser:MyRealPassword" | chpasswd


Do NOT put your real password in:

README.md
Dockerfile
start.sh


Use Railway Variables instead:

RDP_PASSWORD


This keeps the password out of your Git repository.

32. Complete Setup Checklist

Use this checklist if you are doing the setup for the first time.

[ ] Create GitHub account
[ ] Create GitHub repository
[ ] Upload Dockerfile
[ ] Upload start.sh
[ ] Upload README.md
[ ] Create Railway account
[ ] Create Railway project
[ ] Connect GitHub repository
[ ] Wait for Docker build
[ ] Confirm deployment succeeds
[ ] Open Railway Variables
[ ] Create RDP_PASSWORD
[ ] Enter a strong password
[ ] Save the variable
[ ] Redeploy/restart if necessary
[ ] Open Railway Settings
[ ] Find TCP Proxy
[ ] Create TCP Proxy
[ ] Set internal port to 3389
[ ] Copy Railway TCP hostname
[ ] Copy Railway TCP external port
[ ] Open Windows 10
[ ] Press Windows + R
[ ] Run mstsc
[ ] Enter Railway TCP hostname:port
[ ] Connect
[ ] Username = railwayuser
[ ] Password = your RDP_PASSWORD
[ ] Ubuntu XFCE desktop should appear

33. Final Connection Example

Suppose Railway gives you:

TCP Host:
abc123.proxy.rlwy.net

TCP Port:
18472


In Windows Remote Desktop, enter:

abc123.proxy.rlwy.net:18472


Then:

Username:
railwayuser


and:

Password:
YOUR_RDP_PASSWORD


Your actual Railway hostname and port will be different.

34. Final Architecture

The completed setup is:

                  INTERNET
                     |
                     |
              Windows 10 PC
                     |
                     | RDP
                     |
                     v
        Railway TCP Proxy
        hostname:port
                     |
                     |
                     v
        +-----------------------+
        |   Railway Container   |
        |                       |
        |   Ubuntu 22.04        |
        |        |              |
        |      XRDP :3389        |
        |        |              |
        |      XFCE              |
        |        |              |
        |   Ubuntu Desktop      |
        +-----------------------+

35. Important Reminder

The three important values are:

RDP Host:
<provided by Railway TCP Proxy>

RDP Port:
<provided by Railway TCP Proxy>

RDP Username:
railwayuser


And the password is:

RDP_PASSWORD


which you set in Railway Variables.

Do not use the Railway HTTP/HTTPS domain for RDP.

Use the Railway TCP Proxy address.

36. Quick Version

Once everything has been configured, connecting is simply:

Windows 10
    ↓
mstsc
    ↓
<RAILWAY-TCP-HOST>:<RAILWAY-TCP-PORT>
    ↓
Username: railwayuser
    ↓
Password: value of RDP_PASSWORD
    ↓
Ubuntu XFCE Desktop


That's it.

:::

### One correction I'd make to the project itself

There's one thing I'd improve before you push this: **don't use a fallback password in `start.sh`**. If you accidentally forget to set `RDP_PASSWORD`, the container shouldn't quietly start with a known/default password.

I recommend changing this:

```bash
RDP_PASSWORD="${RDP_PASSWORD:-ChangeMe123!}"


to a required variable check:

if [ -z "$RDP_PASSWORD" ]; then
    echo "ERROR: RDP_PASSWORD is not set."
    echo "Please add RDP_PASSWORD in Railway Variables."
    exit 1
fi


That way, a missing password causes the deployment to fail rather than exposing an easily guessed RDP credential.
