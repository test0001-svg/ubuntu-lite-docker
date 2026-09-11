# Ubuntu XFCE XRDP on Railway

Ubuntu 22.04 with XFCE desktop and XRDP, designed to run as a Docker container on Railway and be accessed using Windows Remote Desktop.

## Features

- Ubuntu 22.04
- XFCE lightweight desktop
- XRDP
- Windows Remote Desktop compatible
- Railway TCP Proxy compatible
- RDP password configured through Railway environment variable
- No RDP password stored in the Git repository

## Project Structure

```text
ubuntu-rdp/
├── Dockerfile
├── start.sh
└── README.md

Deploy to Railway

Push this repository to GitHub.

Then create a new Railway project and deploy the GitHub repository.

Railway will automatically detect the Dockerfile and build the container.

Railway Variable

Add this environment variable in Railway:

RDP_PASSWORD=YourStrongPasswordHere


Use a strong password.

Do NOT put your real password in this GitHub repository.

Railway Networking

XRDP listens inside the container on:

3389


You need to create a Railway TCP Proxy for port:

3389


Railway will provide a public TCP hostname and external port.

It may look similar to:

something.proxy.rlwy.net:12345


The hostname and port shown by Railway are the values you should use.

Windows 10 Connection

Open:

Remote Desktop Connection


or run:

mstsc


In the Computer field enter the Railway TCP Proxy address:

something.proxy.rlwy.net:12345


Then connect.

Use:

Username: railwayuser
Password: the value of RDP_PASSWORD

Important

Do not use the default password in production.

Set a strong Railway variable:

RDP_PASSWORD=YourStrongRandomPassword


The container automatically sets the Linux user's password when it starts.

Architecture
Windows 10
     |
     | RDP
     v
Railway TCP Proxy
     |
     | TCP
     v
Container :3389
     |
     v
XRDP
     |
     v
XFCE
     |
     v
Ubuntu 22.04

Troubleshooting
RDP cannot connect

Check that the Railway TCP Proxy is configured for the container port:

3389


Do not use the HTTP public domain for RDP.

Use the TCP Proxy hostname and external port.

RDP connects but immediately disconnects

Check the Railway deployment logs.

The container should show messages indicating:

Starting XRDP session manager...
Starting XRDP server on port 3389...

Black screen

Make sure XFCE is installed and /home/railwayuser/.xsession exists.

The Dockerfile in this repository configures:

startxfce4


for the XRDP session.

Security

A public RDP endpoint will be scanned by automated bots.

Use a strong password and avoid exposing sensitive services through the desktop.

Do not commit passwords, SSH keys, API keys, or other secrets to GitHub.

:::

## Before you push

Your GitHub repository should look exactly like:

```text
ubuntu-rdp/
│
├── Dockerfile
├── start.sh
└── README.md


Then push it:

git init
git add .
git commit -m "Add Ubuntu XFCE XRDP Railway deployment"
git branch -M main
git remote add origin YOUR_GITHUB_REPOSITORY_URL
git push -u origin main


After deploying on Railway, set:

RDP_PASSWORD=your-strong-password


Then create the TCP Proxy → port 3389.

Important: don't use Railway's normal https://....up.railway.app domain in Windows Remote Desktop. You need the TCP Proxy hostname + TCP proxy port for RDP.
