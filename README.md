# 🖥️ Ubuntu XFCE + XRDP on Railway

<p align="center">
  <strong>Run a lightweight Ubuntu desktop on Railway and connect from Windows 10 using Remote Desktop.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Ubuntu-22.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white" alt="Ubuntu 22.04">
  <img src="https://img.shields.io/badge/XFCE-Desktop-2284F2?style=for-the-badge&logo=xfce&logoColor=white" alt="XFCE">
  <img src="https://img.shields.io/badge/XRDP-RDP-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="XRDP">
  <img src="https://img.shields.io/badge/Railway-Deploy-0B0D0E?style=for-the-badge&logo=railway&logoColor=white" alt="Railway">
</p>

<p align="center">
  <em>Ubuntu 22.04 • XFCE • XRDP • Docker • Railway • Windows RDP</em>
</p>

---

## ✨ What Is This?

This project provides a lightweight **Ubuntu 22.04 graphical desktop** running inside a Docker container.

It uses:

- 🐧 **Ubuntu 22.04** — Linux base system
- 🖥️ **XFCE** — lightweight graphical desktop
- 🔐 **XRDP** — Remote Desktop Protocol server
- 🐳 **Docker** — containerized environment
- 🚂 **Railway** — cloud deployment
- 🪟 **Windows Remote Desktop** — connect from Windows 10

Once deployed, you can connect to the Ubuntu desktop from Windows using the built-in **Remote Desktop Connection** application.

No Ubuntu installation is required on your Windows computer.

---

## 🎯 How It Works

```text
┌──────────────────────┐
│      Windows 10      │
│                      │
│  Remote Desktop      │
│      (mstsc)         │
└──────────┬───────────┘
           │
           │ RDP / TCP
           ▼
┌──────────────────────┐
│   Railway TCP Proxy  │
│                      │
│ hostname : port      │
└──────────┬───────────┘
           │
           │ TCP
           ▼
┌────────────────────────────────┐
│       Railway Container        │
│                                │
│        Ubuntu 22.04            │
│              │                 │
│          XRDP :3389             │
│              │                 │
│            XFCE                │
│              │                 │
│       Ubuntu Desktop           │
└────────────────────────────────┘
```

---

## 📦 Project Structure

Your GitHub repository should contain:

```text
ubuntu-rdp/
├── Dockerfile
├── start.sh
└── README.md
```

### `Dockerfile`

The `Dockerfile` builds the Ubuntu environment and installs:

- XFCE
- XFCE utilities
- XRDP
- Xorg
- D-Bus
- Sudo
- Required utilities

### `start.sh`

The `start.sh` script runs when the container starts.

It:

- Reads the RDP password from Railway.
- Sets the password for `railwayuser`.
- Starts D-Bus.
- Starts `xrdp-sesman`.
- Starts XRDP on port `3389`.

---

## 🚀 Beginner Setup Guide

Don't worry if you have never used Docker, Railway, or XRDP before.

Follow the steps below in order.

---

### 1️⃣ Create a GitHub Repository

Go to GitHub and create a new repository.

Recommended name:

```text
ubuntu-rdp
```

You can make the repository:

- 🔒 **Private** — recommended
- 🌎 **Public** — if you want to share the project

Your repository should eventually contain:

```text
Dockerfile
start.sh
README.md
```

> ⚠️ Never put your real password inside the GitHub repository.

---

### 2️⃣ Upload the Project Files

Upload these three files:

```text
Dockerfile
start.sh
README.md
```

The repository should look like:

```text
ubuntu-rdp/
├── Dockerfile
├── start.sh
└── README.md
```

---

### 3️⃣ Create a Railway Account

Create an account on Railway.

After logging in, create a new project.

Choose the option to deploy from your GitHub repository.

Select:

```text
ubuntu-rdp
```

Railway will detect the `Dockerfile` automatically.

You do not need to manually install Ubuntu, Docker, XFCE, or XRDP on your computer.

---

### 4️⃣ Wait for Railway to Build

Railway will read the `Dockerfile` and build the container.

The first build may take several minutes because XFCE and XRDP need to be installed.

Wait until the deployment finishes successfully.

You should see your service running.

---

### 🔐 5️⃣ Set Your RDP Password

This is one of the most important steps.

Open your Railway project.

Go to your service and find:

```text
Variables
```

Create a new environment variable.

#### Variable name

```text
RDP_PASSWORD
```

#### Variable value

Choose your own strong password.

For example:

```text
MyUbuntu!Desktop_7284
```

So your Railway variable should look like:

```env
RDP_PASSWORD=MyUbuntu!Desktop_7284
```

> 🔒 The password above is only an example. Create your own password.

---

## 🔑 RDP Login Information

Your RDP username is:

```text
railwayuser
```

Your RDP password is whatever you entered as:

```text
RDP_PASSWORD
```

For example:

```text
Username: railwayuser
Password: MyUbuntu!Desktop_7284
```

---

## 💡 Why Use a Railway Variable?

The password should not be written directly into the:

```text
Dockerfile
```

or:

```text
start.sh
```

and should never be committed to GitHub.

Instead:

```text
Railway Variable
       │
       │ RDP_PASSWORD
       ▼
   Container
       │
       ▼
railwayuser password
```

This keeps your password out of the source code.

---

### 🔄 6️⃣ Redeploy After Adding the Password

After adding:

```text
RDP_PASSWORD
```

Railway may automatically redeploy your service.

If it does not, restart or redeploy the service manually.

The container needs to restart so that it receives the new variable.

---

### 🌐 7️⃣ Configure Railway TCP Proxy

This step is required.

RDP uses TCP, while a normal Railway public domain is intended for web traffic.

Your container listens for RDP on:

```text
3389
```

Go to your Railway service:

```text
Settings
   ↓
Networking
   ↓
TCP Proxy
```

Create a TCP Proxy for:

```text
3389
```

---

## ⚠️ Important: HTTP Domain ≠ RDP Address

Railway may provide an address similar to:

```text
https://your-project.up.railway.app
```

❌ Do not use this for Windows Remote Desktop.

You need the TCP Proxy address.

Railway will provide something similar to:

```text
something.proxy.rlwy.net:12345
```

✅ This is what you use for RDP.

---

### 📡 8️⃣ Find Your TCP Proxy Address

After creating the TCP Proxy, Railway will show you the public TCP hostname and port.

For example:

```text
Hostname:
abc123.proxy.rlwy.net

Port:
18472
```

Your actual values will be different.

Combine them like this:

```text
abc123.proxy.rlwy.net:18472
```

Keep this address available.

You will enter it into Windows Remote Desktop.

---

### 🪟 9️⃣ Connect From Windows 10

On your Windows 10 computer:

Press:

```text
Windows Key + R
```

A small Run window will appear.

Type:

```powershell
mstsc
```

Then press:

```text
Enter
```

Windows will open:

```text
Remote Desktop Connection
```

---

### 🖥️ 🔟 Enter the Railway RDP Address

Find the:

```text
Computer:
```

field.

Enter your Railway TCP Proxy address.

For example:

```text
abc123.proxy.rlwy.net:18472
```

Then click:

```text
Connect
```

---

### 🔑 1️⃣1️⃣ Enter Your Credentials

Windows will ask for your login credentials.

Use:

```text
Username
railwayuser

Password
```

Use the password you created in Railway:

```text
MyUbuntu!Desktop_7284
```

For example:

```text
Username: railwayuser
Password: MyUbuntu!Desktop_7284
```

---

### 🎉 1️⃣2️⃣ Ubuntu Desktop

If everything is configured correctly, Windows Remote Desktop should open your Ubuntu XFCE desktop.

You should now have:

```text
Windows 10
     │
     │ RDP
     ▼
Railway
     │
     ▼
Ubuntu 22.04
     │
     ▼
XFCE Desktop
```

🎉 You are now remotely connected to Ubuntu.

---

## 🔍 Check Railway Logs

If you want to verify that XRDP started correctly, open:

```text
Railway
   ↓
Your Service
   ↓
Deployments
   ↓
Logs
```

You should see messages similar to:

```text
Ubuntu XFCE + XRDP
User: railwayuser
Setting RDP password...
Starting XRDP session manager...
Starting XRDP server on port 3389...
```

The exact formatting may be different.

The important part is that XRDP starts successfully.

---

## 🛠️ Troubleshooting

### ❌ RDP Cannot Connect

Check these items in order.

#### 1. Is the Railway service running?

Make sure the deployment completed successfully.

#### 2. Is TCP Proxy enabled?

Make sure you created a TCP Proxy pointing to:

```text
3389
```

#### 3. Are you using the TCP address?

Correct:

```text
abc123.proxy.rlwy.net:18472
```

Incorrect:

```text
https://abc123.up.railway.app
```

#### 4. Are you using the correct port?

Railway may give you an external port such as:

```text
18472
```

Use:

```text
hostname:18472
```

Do not automatically assume the public port is `3389`.

---

### ❌ Login Failed

Your username should be exactly:

```text
railwayuser
```

Your password should be the current value of:

```text
RDP_PASSWORD
```

in Railway Variables.

Make sure you did not accidentally create:

```text
PASSWORD
```

or:

```text
RDP_PASS
```

The variable must be:

```text
RDP_PASSWORD
```

---

### ❌ Black Screen After Login

If RDP connects but you get a black screen or are immediately disconnected:

- Check Railway logs.
- Confirm XFCE installed successfully.
- Confirm XRDP started successfully.
- Restart or redeploy the Railway service.

The project configures XFCE as the XRDP desktop session.

---

### ❌ Password Doesn't Work

Go to:

```text
Railway
   ↓
Your Service
   ↓
Variables
```

Check:

```text
RDP_PASSWORD
```

For example:

```env
RDP_PASSWORD=MyNewPassword!927
```

Then restart or redeploy the service.

Use:

```text
Username: railwayuser
Password: MyNewPassword!927
```

---

## 🔐 Security

### Use a Strong Password

A public RDP endpoint can be discovered by automated internet scanners.

Do not use passwords such as:

```text
123456
password
admin
ubuntu
RailwayPassword123
```

Use a strong password containing:

- ✅ Uppercase letters
- ✅ Lowercase letters
- ✅ Numbers
- ✅ Special characters
- ✅ 12+ characters

Example:

```text
MyUbuntu!Desktop_7284
```

This is an example only. Do not use the example password.

---

### 🚫 Never Commit Secrets

Never put these in GitHub:

- ❌ Real RDP password
- ❌ API keys
- ❌ SSH private keys
- ❌ Access tokens
- ❌ Other secrets

Your RDP password belongs in the Railway environment variable:

```text
RDP_PASSWORD
```

---

## 💾 Important: Container Storage

This project runs Ubuntu inside a Railway container.

A container is not the same thing as a traditional VPS.

The container may be restarted, redeployed, or replaced.

Therefore, do not assume that files saved inside the container will always survive a redeployment.

If you need permanent files or data, configure appropriate persistent storage separately.

---

## 👤 RDP User

The default RDP username is:

```text
railwayuser
```

For a beginner setup, it is recommended to leave the username unchanged.

The password can be changed at any time through:

```text
Railway → Variables → RDP_PASSWORD
```

---

## 📋 Complete Setup Checklist

Use this checklist if you are doing the setup for the first time.

- [ ] Create GitHub account
- [ ] Create GitHub repository
- [ ] Upload `Dockerfile`
- [ ] Upload `start.sh`
- [ ] Upload `README.md`

- [ ] Create Railway account
- [ ] Create Railway project
- [ ] Connect GitHub repository
- [ ] Deploy the project
- [ ] Wait for Docker build
- [ ] Confirm deployment succeeds

- [ ] Open Railway Variables
- [ ] Create `RDP_PASSWORD`
- [ ] Set a strong password
- [ ] Save the variable
- [ ] Restart/redeploy if necessary

- [ ] Open Railway Settings
- [ ] Open Networking
- [ ] Create TCP Proxy
- [ ] Set internal port to `3389`

- [ ] Copy Railway TCP hostname
- [ ] Copy Railway TCP external port

- [ ] Open Windows 10
- [ ] Press `Windows + R`
- [ ] Run `mstsc`
- [ ] Enter Railway TCP `hostname:port`
- [ ] Click Connect

- [ ] Username = `railwayuser`
- [ ] Password = your `RDP_PASSWORD`

- [ ] Ubuntu XFCE desktop appears

---

## 🔗 Final Connection Example

Suppose Railway gives you:

```text
TCP Host:
abc123.proxy.rlwy.net

TCP Port:
18472
```

Windows Remote Desktop should use:

```text
abc123.proxy.rlwy.net:18472
```

Then:

```text
Username:
railwayuser
```

and:

```text
Password:
your RDP_PASSWORD
```

> ⚠️ `abc123.proxy.rlwy.net:18472` is only an example. Use the actual address provided by your Railway project.

---

## 🧩 Final Architecture

```text
                         INTERNET
                            │
                            │
                            ▼
                  ┌──────────────────┐
                  │    Windows 10    │
                  │                  │
                  │ Remote Desktop   │
                  │      (mstsc)     │
                  └────────┬─────────┘
                           │
                           │ RDP / TCP
                           ▼
                  ┌──────────────────┐
                  │ Railway TCP Proxy│
                  │                  │
                  │ hostname : port  │
                  └────────┬─────────┘
                           │
                           │ TCP
                           ▼
        ┌───────────────────────────────────┐
        │        Railway Container          │
        │                                   │
        │          Ubuntu 22.04             │
        │                │                  │
        │           XRDP :3389              │
        │                │                  │
        │              XFCE                 │
        │                │                  │
        │        Ubuntu Desktop             │
        └───────────────────────────────────┘
```

---

## 📌 Quick Reference

| Setting | Value |
|---|---|
| 🐧 OS | Ubuntu 22.04 |
| 🖥️ Desktop | XFCE |
| 🔐 Remote Protocol | XRDP / RDP |
| 🔌 Container Port | 3389 |
| 👤 Username | railwayuser |
| 🔑 Password Variable | RDP_PASSWORD |
| ☁️ Hosting | Railway |
| 🪟 Client | Windows Remote Desktop |
| 🛜 Public Access | Railway TCP Proxy |

---

## 🚀 Quick Start

If you already understand the setup, the entire process is:

```text
1. Push this project to GitHub
          ↓
2. Deploy the GitHub repository on Railway
          ↓
3. Add Railway Variable:
   RDP_PASSWORD=your-strong-password
          ↓
4. Create Railway TCP Proxy → 3389
          ↓
5. Copy Railway TCP hostname:port
          ↓
6. Open mstsc on Windows 10
          ↓
7. Enter hostname:port
          ↓
8. Username: railwayuser
          ↓
9. Enter your RDP_PASSWORD
          ↓
10. Enjoy Ubuntu XFCE 🎉
```

---

## ⭐ Notes

This project is intended as a simple way to run an Ubuntu graphical desktop in a Railway container and access it remotely using RDP.

For production or sensitive workloads, consider additional security controls rather than exposing RDP directly to the public internet.

---

<p align="center">
  <strong>🖥️ Ubuntu + XFCE + XRDP + Railway</strong><br>
  <sub>Simple remote Ubuntu desktop over RDP.</sub>
</p>
