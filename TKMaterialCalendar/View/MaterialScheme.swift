//
//  MaterialScheme.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import Foundation
import MaterialComponents

class MaterialScheme {

    static let shared = MaterialScheme()

    private init() {
        self.containerScheme.colorScheme = self.colorScheme
        self.containerScheme.typographyScheme = self.typographyScheme
    }

    let containerScheme = MDCContainerScheme()

    let colorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme(defaults: .material201804)
        scheme.primaryColor = R.color.colorPrimary.uiColor
        scheme.primaryColorVariant = R.color.colorPrimaryVariant.uiColor
        scheme.onPrimaryColor = R.color.colorOnPrimary.uiColor
        scheme.secondaryColor = R.color.colorSecondary.uiColor
        scheme.onSecondaryColor = R.color.colorOnSecondary.uiColor
        scheme.surfaceColor = R.color.colorSurface.uiColor
        scheme.onSurfaceColor = R.color.colorOnSurface.uiColor
        scheme.backgroundColor = R.color.colorBackground.uiColor
        scheme.onBackgroundColor = R.color.colorOnBackground.uiColor
        scheme.errorColor = R.color.colorError.uiColor
        return scheme
    }()

    let typographyScheme: MDCTypographyScheme = {
        let scheme = MDCTypographyScheme()
        return scheme
    }()

    func defaultRippleTouchController() -> MDCRippleTouchController {
        let res = MDCRippleTouchController()
        res.rippleView.rippleColor = colorScheme.rippleColor
        return res
    }

    func defaultSnackBarManager() -> MDCSnackbarManager {
        let res = MDCSnackbarManager()
        res.messageElevation = ShadowElevation(1)
        res.snackbarMessageViewBackgroundColor = colorScheme.snackbarBackgroundColor
        res.messageTextColor = colorScheme.snackbarTextColor
        return res
    }

}

extension MDCSemanticColorScheme {
    var snackbarBackgroundColor: UIColor {
        R.color.colorOnSurface.uiColor
    }

    var snackbarTextColor: UIColor {
        R.color.colorSurface.uiColor
    }

    var rippleColor: UIColor {
        R.color.colorOnSurface.uiColor.withAlphaComponent(0.1)
    }
}
