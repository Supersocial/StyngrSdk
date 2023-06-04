# What is the Styngr SDK?

The Supersocial x Styngr SDK provides developers with simple API surfaces that, when leveraged, allow players to listen to exclusively licensed music from top artists. This functionality is known as the Boombox.

The SDK works hand and hand with Styngr’s backend, the key to this functionality. When a user plays a playlist, skips a song, or purchases more streams, the actions are federated by Styngr’s backend to ensure security and reliability.

The installation and setup of the Styngr SDK is meant to be simple and straightforward. The only required setup is basis authentication with the Styngr backend, and a binding to UI button for users to open and close the boombox.

# Installation and Usage

## Step 1: Download the latest release

### Rojo Users

1. Download the latest .zip release [here](https://github.com/Supersocial/StyngrSdk/releases/latest)

2. Unzip the file, and move the contents of the folders to their specified location

a. I.e contents of `ServerScriptService` folder are placed in `ServerScriptService`

### Vanilla Studio Users

1. Download the latest release [here](https://github.com/Supersocial/StyngrSdk/releases/latest)

2. Drag the .rbxl into Roblox Studio

3. Move the contents of the folders to their specified location

a. I.e contents of `ServerScriptService` folder are placed in `ServerScriptService`

## Step 2: Bootstrapping the SDK

**This particular implementation detail will vary based on the architecture of your codebase.**

Once the SDK has been installed into your codebase, the next step is to bootstrap it. This will make the necessary calls to the backend, as well as secure the authentication tokens needed for the functionality.

Here's some example code of the SDK being initialized

```lua
local StyngrService = require("path.to.StyngrService")

StyngrService:SetConfiguration({
    apiKey = "...",
    appId = "...",
})
```

**This code should be run somewhere before the** `StyngrSdk` **is interacted with**

## Step 3: Binding SDK UI

This SDK uses Fusion to generate a pre-designed User Interface. You'll most likely want to bind this User Interface to a button you control.

Here's some example code of the SDK UI being toggled by a button

```lua
local StyngrClient = require("path.to.StyngrClient")

-- Initialise the client service
StyngrClient:Init()

-- Disable the Styngr-provided button
StyngrClient:SetVisible(false)

SomeUiButton.MouseButton1Down:Connect(function()
    StyngrClient:Toggle()
end)
```

## Step 4: Test the Implementation

At this point, the SDK has been installed, initialized, authenticated and bound to a UI button. The last step is to test the implementation to ensure it has been integrated properly.