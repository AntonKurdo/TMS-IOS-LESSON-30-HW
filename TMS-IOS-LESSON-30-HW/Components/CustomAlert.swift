import UIKit

protocol CustomAlertDelegate: AnyObject {
    func onSuccessTapped(url: String)
}

class CustomAlert: UIView {
    struct Constants {
        static let alpha = 0.5
        static let alertHorizontalMargin: CGFloat = 20
        static let alertHeight: CGFloat = 310
    }
    
    weak var delegate: CustomAlertDelegate?
    
    var backgroundView: UIView!
    
    var textField: UITextField!
    
    var alertView: UIView!
    
    private var keyboardHelper: KeyboardHelper?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        keyboardHelper = KeyboardHelper {  animation, keyboardFrame, duration in
            switch animation {
            case .keyboardWillShow:
                UIView.animate {
                    self.alertView.frame = CGRect(x: Constants.alertHorizontalMargin, y: 175 , width: self.backgroundView.bounds.width - Constants.alertHorizontalMargin * 2, height: Constants.alertHeight)
                }
            case .keyboardWillHide:
                UIView.animate {
                    self.alertView.center = self.backgroundView.center
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showAlert(title: String, vc: UIViewController) {
        
        guard let targetView  = vc.view else { return  }
        
        backgroundView = {
            let backgroundView = UIView()
            backgroundView.frame = CGRect(x: 0, y: 0, width: targetView.bounds.width, height: targetView.bounds.height)
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0)
            return backgroundView
        }()
        
        alertView = {
            let alertView = UIView()
            alertView.layer.cornerRadius = 16
            alertView.layer.opacity = 1
            alertView.frame = CGRect(x: Constants.alertHorizontalMargin, y: -Constants.alertHeight, width: backgroundView.bounds.width - Constants.alertHorizontalMargin * 2, height: Constants.alertHeight)
            alertView.backgroundColor = .white
            alertView.alpha = 1
            return alertView
        }()
        
        let titleLabel = {
            let label = UILabel()
            label.text = title
            label.tintColor = .black
            label.font = .boldSystemFont(ofSize: 24)
            label.frame = CGRect(x: 24, y: 24, width: alertView.bounds.width - 48, height: 30)
            label.textAlignment = .center
            return label
        }()
        
        textField = {
            let tf = UITextField()
            tf.tintColor = .black
            tf.placeholder = "Enter url of new image..."
            tf.font = .boldSystemFont(ofSize: 16)
            tf.frame = CGRect(x: 16, y: Int(titleLabel.frame.maxY) + 8, width: Int(alertView.bounds.width) - 32, height: 50)
            tf.adjustsFontSizeToFitWidth = true
            tf.layer.borderColor = UIColor.black.cgColor
            tf.layer.borderWidth = 0.5
            tf.layer.cornerRadius = 8
            tf.leftView = UIView(frame: CGRectMake(0, 0, 12, self.frame.height))
            tf.leftViewMode = .always
            return tf
        }()
        
        
        let successBtn = {
            let button = UIButton()
            button.setTitle("Success", for: .normal)
            button.backgroundColor = .systemGreen
            button.layer.cornerRadius = 16
            button.addAction(UIAction(handler: {_ in
                guard let url = self.textField.text, url.count > 0 else {
                    self.textField.shake()
                    return
                }
                let isUrl = verifyUrl(urlString: url)
                if(isUrl) {
                    self.delegate?.onSuccessTapped(url: url)
                    dissmiss()
                } else {
                    self.textField.shake()
                }
            }), for: .touchUpInside)
            return button
        }()
        
        let dismissBtn = {
            let button = UIButton()
            button.setTitle("Cancel", for: .normal)
            button.backgroundColor = .systemRed
            button.layer.cornerRadius = 16
            button.addAction(UIAction(handler: {_ in
                dissmiss()
            }), for: .touchUpInside)
            return button
        }()
        
        let stackView = {
            let stackView = UIStackView()
            stackView.frame = CGRect(x: 16, y: Int(alertView.bounds.height) - 66, width: Int(alertView.bounds.width) - 32, height: 50)
            stackView.spacing = 16
            stackView.distribution = .fillEqually
            return stackView
        }()
        
        stackView.addArrangedSubview(successBtn)
        stackView.addArrangedSubview(dismissBtn)
        alertView.addSubview(titleLabel)
        alertView.addSubview(textField)
        alertView.addSubview(stackView)
        backgroundView.addSubview(alertView)
        targetView.addSubview(backgroundView)
        
        func dissmiss() {
            UIView.animate(withDuration: 0.3, animations: {
                self.alertView.frame = CGRect(x: Constants.alertHorizontalMargin, y: -Constants.alertHeight, width: self.backgroundView.bounds.width - Constants.alertHorizontalMargin * 2, height: Constants.alertHeight)
            }) { done in
                if done {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0)
                    }) { done in
                        if done {
                            self.alertView.removeFromSuperview()
                            self.textField.removeFromSuperview()
                            self.backgroundView.removeFromSuperview()
                            self.backgroundView = nil
                            
                        }
                    }
                }
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(Constants.alpha)
        }) { done in
            if done {
                UIView.animate(withDuration: 0.3,
                               delay: 0.0,
                               usingSpringWithDamping: 0.4,
                               initialSpringVelocity: 0,
                               options: [],
                               animations: {
                    self.alertView.center = self.backgroundView.center
                }) {
                    done in
                    if done {
                        self.textField.becomeFirstResponder()
                    }
                }
            }
        }
        
        let tapGesture = UITapGestureRecognizerWithClosure() { _ in
            dissmiss()
        }
        tapGesture.delegate = self
        
        backgroundView.addGestureRecognizer(tapGesture)
    }
}

extension CustomAlert: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == self.backgroundView {
            return true
        }
        return false
    }
}
