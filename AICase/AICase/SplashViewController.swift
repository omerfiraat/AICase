//
//  SplashViewController.swift
//  AICase
//
//  Created by Ömer Firat on 22.05.2023.
//

import UIKit
import Lottie
import SnapKit

class SplashViewController: UIViewController {
    private var animationView: LottieAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        animationView = LottieAnimationView(name: "vinylAnimation")
        animationView?.loopMode = .loop
        animationView?.contentMode = .scaleAspectFit
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView!)

        animationView?.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        }

        animationView?.play()

        let label = UILabel()
        label.text = "vinbot"
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(animationView!.snp.bottom).offset(16)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showMainScreen()
        }
    }

    func showMainScreen() {
        let chatViewController = ChatViewController()

        UIView.transition(with: view.window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.view.window?.rootViewController = chatViewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: nil)
    }

}
