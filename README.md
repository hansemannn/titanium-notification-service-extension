# Titanium iOS Notification Service Extension

An example implementation of using a native iOS Notification Service Extension (to display images in remote push notification) in Titanium.

## Requirements

- [x] A basic understanding of working with native iOS extensions in Titanium, see [this guide](https://titaniumsdk.com/guide/Titanium_SDK/Titanium_SDK_How-tos/Platform_API_Deep_Dives/iOS_API_Deep_Dives/Creating_iOS_Extensions_-_Siri_Intents.html) for reference.
- [x] A push notification server that can handle own APS payloads, e.g. Firebase Messaging, OneSignal or Urban Airship
- [x] A physical device to test - notification service extensions do not work in Simulator

## Usage

1. Copy the `NotificationServiceExtension` directory to `<project>/extensions`
2. Change the extension app ID (search for `com.example.app`, e.g. in VSCode) to your app identifier
3. Generate a new app ID for the extension in Apple Developer that matches `<your-main-app-id>.MyNotificationServiceExtension`.
> Note: We generated the `MyNotificationServiceExtension` suffix by default. If you wish to change it during app ID creation, make sure to also change it in the code
4. Generate new provisioning profiles matching the new extension app ID (one for development and one for production)
5. Add the following to your tiapp.xml:
```xml
<extensions>
    <extension projectPath="extensions/NotificationServiceExtension/NotificationServiceExtension.xcodeproj">
        <target name="NotificationServiceExtension">
            <provisioning-profiles>
            <device>YOUR_DEVELOPMENT_PROVISIONING_PROFILE_ID</device>
            <dist-appstore>YOUR_PRODUCTION_PROVISIONING_PROFILE_ID</dist-appstore>
            <dist-adhoc>YOUR_PRODUCTION_PROVISIONING_PROFILE_ID</dist-adhoc>
            </provisioning-profiles>
        </target>
    </extension>
</extensions>
```
6. Run the app on your physcial device to make sure it compiles correctly. Validate in the generated Xcode project (in build/iphone/<your-app-name>.xcodeproj) that the app extension was linked correctly.
7. Prepare a sample push notification with the following structure:
```json
{
	"aps": {
		"alert": {
			"title": "My Notification Title",
			"body": "My Notification Message",
		},
		"sound": "default",
		"category": "MyAttachmentCategory",
        "mutable-content": 1
	},
    "attachment": "MY_IMAGE_URL"
}
```
> Note: In this example, the Info.plist restricts the push handling of attachments to `MyAttachmentCategory`. You can change the category or remove this restriction in `NotificationServiceExtension/NotificationServiceExtension/Info.plist`.
8. Send the notification! If it succeeds, the push notification will contain the image at the right side of the notification. 

## Author

Hans Knöchel

## License

MIT