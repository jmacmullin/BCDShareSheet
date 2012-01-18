A Simple Framework For Sharing Content via Email, Facebook and Twitter
======================================================================

There's a number of ways to share content from within iOS apps. iOS5 includes support for sharing content via email and Twitter. There are also libraries like [ShareKit](http://getsharekit.com/) that allow you to share via any number of sharing services. So why use BCDShareSheet?

If your apps only need to share content via email, Twitter and Facebook and you don't want to write the same code each time, then BCDShareSheet might be handy. Otherwise, you might prefer to call the sharing services yourself or to use something like ShareKit that supports more services.

BCDShareSheet requires iOS4 or later and sharing via Twitter is only available on iOS5 (as it uses iOS's built-in support for Twitter).

Building BCDShareSheet
----------------------

Open the BCDShareSheet project in Xcode and run the 'build all' target. This will produce a 'BCDShareSheet.framework' in a 'Products' directory within the top-level BCDShareSheet directory. It is a universal framework that can be used both within the simulator and on devices.

Dependencies
------------

Before you can use BCDShareSheet you'll need to make sure you have all of the frameworks/libraries that it depends upon.

For sharing content you'll need to add the following frameworks to your project:

- MessageUI.framework (part of the iOS SDK, used to send email)
- Twitter.framework (part of the iOS SDK, used to send tweets)

*Please Note* - You should weakly link the Twitter.framework if you want your app to run on iOS4. ABCiOSKit will only attempt to share via Twitter if the framework is present.

Adding the Framework to Your Project
------------------------------------

- Select your project at the root level of Xcode's Project Navigator.
- Select your project's target and click on the 'Build Phases' tab.
- Expand the 'Link Binary With Libraries' section.
- Click on the '+' button to add a new library/framework.
- Click on the 'Add Other...' button at the bottom of the sheet that appears.
- Browse to the 'BCDShareSheet.framework' directory and click 'Open'

Using the Framework to Share Something
--------------------------------------
BCDShareSheet can be used for sharing content via email, Facebook and Twitter (Twitter is only available on iOS5 or later). Before you use this framework in your code, you need to make sure you've set up an appropriate Facebook App to use to share content. To do this, read through [Facebook's iOS Tutorial](https://developers.facebook.com/docs/mobile/ios/build/).

You won't need to write all the code outlined in the tutorial as much of this is handled by the BCDShareSheet, but *you will need to complete 'Step 1: Registering your iOS App with Facebook'* and the part of 'Step 3: Implementing Single Sign-On (SSO)' under the heading *'Modify the app property list file'*.

Once you've done this, you will need to write a small amount of code.

In your app's delegate you'll need to do the following:

Import the BCDShareSheet framework:

``` objective-c
import <BCDShareSheet/BCDShareSheet.h>
```
	
In your delegate's implementation of application:didFinishLaunchingWithOptions: you should configure the 'BCDShareSheet'. You must provide a 'rootViewController' and 'facebookAppID' and you can optionally specify an 'appName':

``` objective-c
BCDShareSheet *sharer = [BCDShareSheet sharedSharer];
[sharer setRootViewController:self.viewController];
[sharer setFacebookAppID:@"123456789123456789"];
[sharer setAppName:@"Test App"];
```
	
In order to authenticate with Facebook, apps are now required to support 'single sign-on'. This means that if the user of your app has the Facebook iOS app installed then when s/he attempts to share something from your app via Facebook for the first time, your app will be suspended and the Facebook iOS app will be launched where the user will be prompted to allow your app to access his/her Facebook account. Once the user has granted this permission your app will be resumed by being asked to open a URL using the custom URL scheme you set up earlier. The request that resumes your app will contain credentials you can use for sharing via Facebook in the future. BCDShareSheet handles most of the details of this for you, but you will still need to handle the request to open the URL in your app's delegate. If you haven't already done so, implement the application:openURL:sourceApplication:annotation: method in your app's delegate and pass any requests that start with 'fb' to the BCDShareSheet class.

``` objective-c
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[url scheme] hasPrefix:@"fb"]) {
        return [[BCDShareSheet sharedSharer] openURL:url];
    } else {
        return NO; // handle any other URLs your app responds to here.
    }
}
```

Finally, once you've configured BCDShareSheet and implemented application:openURL:sourceApplication:annotation: you can use BCDShareSheet to share stuff. All you need to do is create a shareable item and ask BCDShareSheet for a sheet to share it with:

``` objective-c
BCDShareableItem *item = [[BCDShareableItem alloc] initWithTitle:@"A cat in a cutlery rack"];
[item setDescription:@"A cat in a cutlery rack, what more can I say?"];
[item setItemURLString:@"http://icanhascheezburger.com/2011/11/21/funny-pictures-drainin-dah-catlery/"];
[item setImageURLString:@"http://icanhascheezburger.files.wordpress.com/2011/11/funny-pictures-drainin-dah-catlery.jpg"];
 
UIActionSheet *sheet = [[BCDShareSheet sharedSharer] sheetForSharing:item completion:^(BCDResult result) {
   if (result==BCDResultSuccess) {
      NSLog(@"Yay!");
   }
}];
[sheet showInView:self.view];
```

License
-------

BCDShareSheet is available under the MIT license. See the LICENSE file for more info.
