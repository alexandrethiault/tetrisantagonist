# Tetris Antagonist

Source code for the Tetris Antagonist mobile application

## Compilation

In order to compile a debug version of the app, you need to open the code as a Flutter project in Android Studio. See [Flutter's website](https://flutter.dev/docs/get-started/install) for detailed instructions on how to install Android Studio, and how to install Flutter on Android Studio.

Compilation is done upon clicking the green arrow button in Android Studio, with the condition that you have installed an emulator of a compatible phone, for the code to run on, or you have linked to your computer a physical Android phone with developer mode switched on. In the latter case, the cable linking the phone to the computer can be removed after the first compilation, and the app will still be installed and usable by clicking the "tetrisserver" app, found in the list of applications of the phone. This way, it's possible to install the same debug app on several phones, one after the other.

To create a release version of the app, for Android only, run the following command in a terminal at the root of the project:

`flutter build apk --split-per-abi --no-tree-shake-icons --no-shrink --no-sound-null-safety`

This will produce serveral APK files, including one called `app-armeabi-v7a-release.apk`, found in `build/app/outputs/flutter-apk/`. This APK file can then be send on an Android phone. Clicking it should install the app if the phone is compatible. Warning messages requiring a permission to install an app from unknown sources may happen.

## Usage

In order to connect together, phones or tablets with the app installed must switch wi-fi, geolocation, and bluetooth on, and they shouldn't be more than a few meters apart.

Home screen lets you choose a role, either HOST or JOIN. Only one device should click on HOST, all others should click on JOIN. While the app displays both possibilities for all users, layouts have been optimized for tablets to use HOST and phones to use JOIN.

Clicking on HOST will make the device start advertising itself and become visible to others. Other devices, after clicking on JOIN will then see a screen prompting them to connect to the tablet. Click the green CONNECT button and wait for the connection to happen. This step shouldn't take more than a few seconds.

When all players are ready, the host should click on its Start button to start the game.

Host is where the game is displayed while other players' devices are used as controllers to act on that game screen. One of the players will be an antagonist, and have the associated controller layout. The others will be players, and have the player controller layout.

In the case of a disconnection of one of the players, they can still try to reconnect but the game roles may have been switched after the disconnection.

The game is not meant to be started with only 1 player, but we're not blocking you to do so. Undesirable or unexpected role attribution may happen in this case.
