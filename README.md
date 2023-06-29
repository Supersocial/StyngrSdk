# What is the Styngr SDK?

The Supersocial x Styngr SDK provides developers with simple API surfaces that, when leveraged, allow players to listen to exclusively licensed music from top artists. This functionality is known as the Boombox.

The SDK works hand and hand with [Styngr’s backend](#styngr-backend), the key to this functionality. When a user plays a playlist, skips a song, or purchases more streams, the actions are federated by Styngr’s backend to ensure security and reliability.

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
	boombox = {
		textureId = "..."
	}
})
```

You'll need to provide a `textureId` for the boombox. This is the "skin" that's applied to the physical boombox that's shown when a Player is listening to music.

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

# Styngr Backend

The Styngr backend consists of a set of APIs enabling clients to build radio-like user experiences that are in line with the DMCA rulesets.

Styngr takes care of the legal and licensing aspects of dealing with the major labels which enables the game developers to focus on implementing the best experiences for their users.

The geo-availability of audio assets is dictated by the label owners, who also reserve full rights to add support for new territories or remove support for the existing ones.

## Geo-blocking

Depending on the client's geolocation, access to certain content provided by Styngr may be restricted. To achieve this, Styngr stores clients' geolocation in the JWT when they are successfully authenticated and uses this information every time a request comes in.

Based on the client's technical implementation and architecture, Styngr offers two following solutions for geo-blocking:

1. Styngr APIs approximate the client's geolocation by looking up the source IP address of every HTTP request. The user's location is determined by searching for the public IP address in Styngr's database which is periodically synchronized with data from MaxMind.

2. In case when the client application or the SDK integrates with Styngr APIs via a proxy server, the client's geolocation can no longer reliably be determined by looking up the source IP address in the HTTP request. Therefore, the client is advised to use the `V2` version of the token endpoint (`POST /api/v2/sdk/tokens`). This endpoint expects the `countryCode` in ISO 3166, alpha-2 format to be passed in the request body.

### How It Works

1.	Client authenticates with the Styngr backend by calling one of the available token endpoint versions. 
2.	Styngr API extracts the client's public IP address from the HTTP request when `V1` token endpoint is called or uses the `countryCode` value from the HTTP request body when the `V2` token endpoint is called.
3.	If the client authenticated via `V1` token endpoint, Styngr API uses the previously extracted public IP address to approximate the client’s geolocation by looking up the MaxMind database from which the country information is retrieved.
4.	Styngr API cross-references the country information with internal database that holds tracks metadata to determine whether there are any applicable geographical restrictions for the requested audio asset.
5.	If the audio asset is eligible for use from the client’s country, Styngr API returns the URL or other identifier which can be used to access the requested audio asset.
6.	In case the audio asset is not eligible for use from the client’s country, Styngr API throws an exception, and the client application is responsible for handling the response. 


## Track Randomization

Styngr APIs are using a custom algorithm that enables the track selection to comply with the DMCA rules as closely as possible. This functionality is provided out of the box when integrating with Styngr's APIs directly or via SDKs.

### How It Works

Every playlist has information about the total playlist duration, labels, and number of tracks per label in the playlist. For every user, the Styngr API creates a unique playlist session, which is used to keep track of songs that are played. The playlist session is also used to track the skips. The users are limited to 6 skips per playlist session.

The track selection algorithm relies on record label playback target percentages. This is an optional value in Styngr's system that defines how many tracks from the total playback duration should belong to a particular label. To achieve this, Styngr tracks playback statistics across all playlists and all playlist sessions. Whenever a track is played, the counter for the label owner is incremented by one, indicating the number of tracks played for a particular label.

# User Flow

This section describes the expected user flow when using the radio. In the following text, the user or the application calling the Styngr APIs will be referred to as the `client`, whereas the service provider i.e. the Styngr APIs will be referred to as the `server`.

1. The client toggles the boombox UI by clicking on a UI button in game.
	- In the background, the server performs the authentication and returns the response to the client.
2. If authenticated successfully, the client is able to browse through available playlists.
3. The client selects one of the available playlists to start listening session.
	- In the background, the server creates a validates the request and creates the playlist session for the current client.
	- The server then returns the seed track (a predetermined track from which the playlist starts) or a random track if no seed tracks are configured.
4. The client listens to the track.
	- The client is able to pause/resume the current track or skip to the next one.
	- At no point in time does the client know which track is going to be next. 
	- The randomization algorithm that's running on the server takes care of the track selection.
5. The client skips to the next track.
	- The client sends playback statistics to the server every time the next track is requested.
6. The client exits the listening session by closing the boombox or by listening the entire playlist to the end.
	- A new listening sessions is started by simply selecting one of the available playlists.