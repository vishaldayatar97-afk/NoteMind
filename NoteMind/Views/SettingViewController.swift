//
//  SettingViewController.swift
//  NoteMind
//
//  Created by VishalD. on 16/08/26.
//
import UIKit
import StoreKit

class SettingsViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var appearanceButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!

    @IBOutlet weak var iCloudSwitch: UISwitch!
    @IBOutlet weak var autoBackupSwitch: UISwitch!

    // MARK: - UserDefaults Keys

    private let appearanceKey = "settings.appearance"
    private let categoryKey = "settings.defaultCategory"
    private let iCloudSyncKey = "settings.iCloudSync"
    private let autoBackupKey = "settings.autoBackup"

    // MARK: - Constants

    private let categories = [
        "Personal",
        "Work",
        "Study",
        "Ideas"
    ]

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSettings()
        loadSettings()
    }

    // MARK: - Setup

    private func setupSettings() {

        title = "Settings"

        // Switch appearance
        iCloudSwitch.onTintColor = .systemPurple
        autoBackupSwitch.onTintColor = .systemPurple

        // Appearance button
        appearanceButton.setTitleColor(
            .secondaryLabel,
            for: .normal
        )

        appearanceButton.titleLabel?.font =
            UIFont.preferredFont(
                forTextStyle: .body
            )

        appearanceButton.contentHorizontalAlignment =
            .right

        // Category button
        categoryButton.setTitleColor(
            .secondaryLabel,
            for: .normal
        )

        categoryButton.titleLabel?.font =
            UIFont.preferredFont(
                forTextStyle: .body
            )

        categoryButton.contentHorizontalAlignment =
            .right
    }

    // MARK: - Load Settings

    private func loadSettings() {

        let defaults =
            UserDefaults.standard

        // MARK: Appearance

        let savedAppearance =
            defaults.string(
                forKey: appearanceKey
            ) ?? "System"

        appearanceButton.setTitle(
            savedAppearance,
            for: .normal
        )

        // MARK: Default Category

        let savedCategory =
            defaults.string(
                forKey: categoryKey
            ) ?? "Personal"

        categoryButton.setTitle(
            savedCategory,
            for: .normal
        )

        // MARK: iCloud

        iCloudSwitch.isOn =
            defaults.bool(
                forKey: iCloudSyncKey
            )

        // MARK: Auto Backup

        if defaults.object(
            forKey: autoBackupKey
        ) == nil {

            defaults.set(
                true,
                forKey: autoBackupKey
            )
        }

        autoBackupSwitch.isOn =
            defaults.bool(
                forKey: autoBackupKey
            )
    }

    // MARK: - Appearance

    @IBAction func appearanceButtonPressed(
        _ sender: UIButton
    ) {

        let alert =
            UIAlertController(
                title: "Appearance",
                message: "Choose your preferred appearance.",
                preferredStyle: .actionSheet
            )

        // System

        let systemAction =
            UIAlertAction(
                title: "System",
                style: .default
            ) { [weak self] _ in

                self?.setAppearance(
                    name: "System",
                    style: .unspecified
                )
            }

        // Light

        let lightAction =
            UIAlertAction(
                title: "Light",
                style: .default
            ) { [weak self] _ in

                self?.setAppearance(
                    name: "Light",
                    style: .light
                )
            }

        // Dark

        let darkAction =
            UIAlertAction(
                title: "Dark",
                style: .default
            ) { [weak self] _ in

                self?.setAppearance(
                    name: "Dark",
                    style: .dark
                )
            }

        // Cancel

        let cancelAction =
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )

        alert.addAction(systemAction)
        alert.addAction(lightAction)
        alert.addAction(darkAction)
        alert.addAction(cancelAction)

        present(
            alert,
            animated: true
        )
    }

    private func setAppearance(
        name: String,
        style: UIUserInterfaceStyle
    ) {

        UserDefaults.standard.set(
            name,
            forKey: appearanceKey
        )

        appearanceButton.setTitle(
            name,
            for: .normal
        )

        view.window?.overrideUserInterfaceStyle =
            style
    }

    // MARK: - Default Category

    @IBAction func categoryButtonPressed(
        _ sender: UIButton
    ) {

        let alert =
            UIAlertController(
                title: "Default Note Category",
                message: "Choose the category used for new notes.",
                preferredStyle: .actionSheet
            )

        for category in categories {

            let action =
                UIAlertAction(
                    title: category,
                    style: .default
                ) { [weak self] _ in

                    guard let self = self else {
                        return
                    }

                    UserDefaults.standard.set(
                        category,
                        forKey: self.categoryKey
                    )

                    self.categoryButton.setTitle(
                        category,
                        for: .normal
                    )
                }

            alert.addAction(action)
        }

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )

        present(
            alert,
            animated: true
        )
    }

    // MARK: - iCloud Sync

    @IBAction func iCloudSwitchChanged(
        _ sender: UISwitch
    ) {

        UserDefaults.standard.set(
            sender.isOn,
            forKey: iCloudSyncKey
        )

        if sender.isOn {

            showInformationAlert(
                title: "iCloud Sync",
                message: "iCloud Sync has been enabled."
            )

        } else {

            showInformationAlert(
                title: "iCloud Sync",
                message: "iCloud Sync has been disabled."
            )
        }
    }

    // MARK: - Auto Backup

    @IBAction func autoBackupSwitchChanged(
        _ sender: UISwitch
    ) {

        UserDefaults.standard.set(
            sender.isOn,
            forKey: autoBackupKey
        )
    }

    // MARK: - Rate App

    @IBAction func rateAppButtonPressed(
        _ sender: UIButton
    ) {

        if let scene =
            view.window?.windowScene {

            SKStoreReviewController.requestReview(
                in: scene
            )

        } else {

            showInformationAlert(
                title: "Rate NoteMind",
                message: "Thank you for using NoteMind!"
            )
        }
    }

    // MARK: - Privacy Policy

    @IBAction func privacyPolicyButtonPressed(
        _ sender: UIButton
    ) {

        showInformationAlert(
            title: "Privacy Policy",
            message: """
            NoteMind stores your notes locally
            on your device.

            AI-generated summaries are processed
            through your configured AI service.

            We do not sell your personal note data.
            """
        )
    }

    // MARK: - Terms of Use

    @IBAction func termsButtonPressed(
        _ sender: UIButton
    ) {

        showInformationAlert(
            title: "Terms of Use",
            message: """
            NoteMind is provided for personal
            productivity and note-taking.

            AI-generated content should be reviewed
            before relying on it.
            """
        )
    }

    // MARK: - About

    @IBAction func aboutButtonPressed(
        _ sender: UIButton
    ) {

        let alert =
            UIAlertController(
                title: "About NoteMind",
                message: """
                NoteMind

                Your intelligent notes companion.

                Create, organize, search and summarize
                your notes with AI.

                Version 1.0
                """,
                preferredStyle: .alert
            )

        alert.addAction(
            UIAlertAction(
                title: "Done",
                style: .default
            )
        )

        present(
            alert,
            animated: true
        )
    }

    // MARK: - Helper Alert

    private func showInformationAlert(
        title: String,
        message: String
    ) {

        let alert =
            UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(
            alert,
            animated: true
        )
    }
}
