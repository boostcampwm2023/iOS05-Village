//
//  SignUpViewController.swift
//  Village
//
//  Created by 정상윤 on 11/27/23.
//

import UIKit
import PhotosUI
import Combine

final class SignUpViewController: UIViewController {
    
    typealias ViewModel = SignUpViewModel
    
    private let viewModel: ViewModel
    
    private let nicknameSubject = PassthroughSubject<String, Never>()
    private let profileImageDataSubject = PassthroughSubject<Data?, Never>()
    private let completeButtonSubject = PassthroughSubject<Void, Never>()
    private var cancellableBag = Set<AnyCancellable>()
    
    private lazy var profileImageView: ProfileImageView = {
        let imageView = ProfileImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageClicked)))
        
        return imageView
    }()
    
    private lazy var nicknameTextField: NicknameTextField = {
        let textField = NicknameTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    private lazy var completeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "완료",
            style: .done,
            target: self,
            action: #selector(completeButtonTapped)
        )
        button.isEnabled = false
        
        return button
    }()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationUI()
        configureUI()
        setLayoutConstraints()
        bindViewModel()
        bindNickname()
        getPreviousInfo()
    }
    
}

private extension SignUpViewController {
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(profileImageView)
        view.addSubview(nicknameTextField)
    }
    
    func setNavigationUI() {
        navigationItem.title = "프로필 설정"
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.rightBarButtonItem = completeButton
    }
    
    func setLayoutConstraints() {
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nicknameTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20)
        ])
    }
    
    func bindViewModel() {
        let output = viewModel.transform(input: ViewModel.Input(
            nicknameInput: nicknameSubject,
            profileImageDataInput: profileImageDataSubject,
            completeButtonSubject: completeButtonSubject
        ))
        
        output.completeButtonEnableOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnable in
                self?.completeButton.isEnabled = isEnable
            }
            .store(in: &cancellableBag)
        
        output.completeButtonOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellableBag)
        
    }
    
    func bindNickname() {
        nicknameTextField.nicknameText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.nicknameSubject.send(nickname)
            }
            .store(in: &cancellableBag)
    }
    
    func getPreviousInfo() {
        let previousInfo = viewModel.getPreviousInfo()
        nicknameTextField.setNickname(nickname: previousInfo.nickname)
        guard let data = previousInfo.profileImage,
              let image = UIImage(data: data) else { return }
        profileImageView.setProfile(image: image)
    }
    
}

@objc
extension SignUpViewController {
    
    func completeButtonTapped() {
        completeButtonSubject.send()
    }
    
    func imageClicked() {
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        DispatchQueue.main.async {
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            picker.isEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        
    }
}
extension SignUpViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        guard let result = results.first else { return }
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, _) in
            guard let image = image as? UIImage else { return }
            let scaleImage = image.resize(newWidth: 100, newHeight: 100)
            DispatchQueue.main.async {
                self?.profileImageView.setProfile(image: scaleImage)
            }
            let data = scaleImage.pngData()
            self?.profileImageDataSubject.send(data)
        }
    }
    
}
