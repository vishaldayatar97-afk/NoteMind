//
//  SceneDelegate.swift
//  NoteMind
//
//  Created by VishalD. on 07/08/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - UserDefaults Key

    private let appearanceKey =
        "settings.appearance"

    // MARK: - Scene Connection

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions:
        UIScene.ConnectionOptions
    ) {

        guard let windowScene =
                scene as? UIWindowScene
        else {
            return
        }

        // If using a storyboard, the window is
        // automatically initialized and attached.

        if let window = window {

            applySavedAppearance(
                to: window
            )

        } else {

            // Find the window belonging to
            // this scene.

            if let window =
                windowScene.windows.first {

                self.window = window

                applySavedAppearance(
                    to: window
                )
            }
        }
    }

    // MARK: - Apply Saved Appearance

    private func applySavedAppearance(
        to window: UIWindow
    ) {

        let savedAppearance =
            UserDefaults.standard.string(
                forKey: appearanceKey
            ) ?? "System"

        switch savedAppearance {

        case "Light":

            window.overrideUserInterfaceStyle =
                .light

        case "Dark":

            window.overrideUserInterfaceStyle =
                .dark

        default:

            window.overrideUserInterfaceStyle =
                .unspecified
        }
    }

    // MARK: - Scene Disconnect

    func sceneDidDisconnect(
        _ scene: UIScene
    ) {

        // Called as the scene is being released
        // by the system.

        // The scene may reconnect later.
    }

    // MARK: - Scene Became Active

    func sceneDidBecomeActive(
        _ scene: UIScene
    ) {

        // Called when the scene becomes active.
    }

    // MARK: - Scene Will Resign Active

    func sceneWillResignActive(
        _ scene: UIScene
    ) {

        // Called when the scene is about to
        // become inactive.
    }

    // MARK: - Scene Will Enter Foreground

    func sceneWillEnterForeground(
        _ scene: UIScene
    ) {

        // Called as the scene transitions
        // from background to foreground.
    }

    // MARK: - Scene Did Enter Background

    func sceneDidEnterBackground(
        _ scene: UIScene
    ) {

        // Save changes in the application's
        // managed object context.

        (
            UIApplication.shared.delegate
                as? AppDelegate
        )?.saveContext()
    }
}
