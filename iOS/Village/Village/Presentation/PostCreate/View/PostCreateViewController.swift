//
//  PostCreateViewController.swift
//  Village
//
//  Created by 조성민 on 11/15/23.
//

import UIKit
import Combine
import PhotosUI

final class PostCreateViewController: UIViewController {
    
    typealias ViewModel = PostCreateViewModel
    
    private let viewModel: ViewModel
    let editButtonTappedSubject = PassthroughSubject<Void, Never>()
    private let editSetSubject = PassthroughSubject<Void, Never>()
    private let postInfoPublisher = PassthroughSubject<PostModifyInfo, Never>()
    private let selectedImagePublisher = PassthroughSubject<[Data], Never>()
    private let deleteImagePublisher = PassthroughSubject<ImageItem, Never>()
    
    private lazy var keyboardToolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        let hideKeyboardButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: nil,
            action: #selector(hideKeyboard)
        )
        let flexibleSpaceButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        toolbar.sizeToFit()
        toolbar.setItems([flexibleSpaceButton, hideKeyboardButton], animated: false)
        toolbar.tintColor = .label
        
        return toolbar
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        
        return stackView
    }()
    
    private lazy var scrollViewBottomConstraint: NSLayoutConstraint = {
        return scrollView.bottomAnchor.constraint(equalTo: postButtonView.topAnchor, constant: 0)
    }()
    
    private lazy var imageUploadView: ImageUploadView = {
        let action = UIAction { [weak self] _ in
            self?.presentPHPickerViewController()
        }
        let view = ImageUploadView(cameraButtonAction: action,
                                   deleteImagePublisher: deleteImagePublisher)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return view
    }()
    
    private let imageWarningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "사진을 1장 이상 등록해야 합니다."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .negative400
        label.alpha = 0
        
        return label
    }()
    
    private lazy var postCreateTitleView: PostCreateTitleView = {
        let view = PostCreateTitleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postCreateStartTimeView: PostCreateTimeView = {
        let view = PostCreateTimeView(isRequest: viewModel.isRequest, timeType: .start)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postCreateEndTimeView: PostCreateTimeView = {
        let view = PostCreateTimeView(isRequest: viewModel.isRequest, timeType: .end)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postCreatePriceView: PostCreatePriceView = {
        let view = PostCreatePriceView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postCreateDetailView: PostCreateDetailView = {
        let view = PostCreateDetailView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let postButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        if viewModel.isEdit {
            configuration.title = "편집완료"
        } else {
            configuration.title = "작성하기"
        }
        configuration.titleAlignment = .center
        configuration.baseBackgroundColor = .primary500
        configuration.cornerStyle = .medium
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(post), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        configureNavigation()
        configureUI()
        configureConstraints()
        setUpNotification()
        bind()
        if viewModel.isEdit {
            editSetSubject.send()
        }
    }
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var cancellableBag: Set<AnyCancellable> = []
    
    private func bind() {
        let input = ViewModel.Input(
            postInfoInput: postInfoPublisher,
            editSetInput: editSetSubject,
            selectedImagePublisher: selectedImagePublisher.eraseToAnyPublisher(),
            deleteImagePublisher: deleteImagePublisher.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        handleWarningResult(output)
        handleEndResult(output)
        handleEditInitOutput(output)
        handleImageOutput(output)
        
    }
    
    private func handleWarningResult(_ output: ViewModel.Output) {
        output.warningResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] warning in
                if let imageWarning = warning.imageWarning {
                    self?.imageWarn(enable: imageWarning)
                }
                self?.postCreateTitleView.warn(warning.titleWarning)
                if let priceWarning = warning.priceWarning {
                    self?.postCreatePriceView.warn(priceWarning)
                }
                if warning.startTimeWarning || warning.endTimeWarning {
                    self?.postCreateStartTimeView.warn(warning.startTimeWarning)
                    self?.postCreateEndTimeView.warn(warning.endTimeWarning)
                } else {
                    self?.postCreateEndTimeView.changeWarn(enable: warning.timeSequenceWarning)
                }
            }
            .store(in: &cancellableBag)
    }
    
    private func handleEndResult(_ output: ViewModel.Output) {
        output.endResult
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            }, receiveValue: { [weak self] in
                self?.dismiss(animated: true)
                self?.navigationController?.popViewController(animated: true)
                
                if self?.viewModel.isEdit == true {
                    self?.editButtonTappedSubject.send()
                }
            })
            .store(in: &cancellableBag)
    }
    
    private func handleEditInitOutput(_ output: ViewModel.Output) {
        output.editInitOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] post in
                self?.postCreateTitleView.titleTextField.text = post.title
                self?.postCreateStartTimeView.setEdit(time: post.startDate)
                self?.postCreateEndTimeView.setEdit(time: post.endDate)
                self?.postCreatePriceView.priceTextField.text = post.price?.priceText()
                self?.postCreateDetailView.detailTextView.text = post.description
            }
            .store(in: &cancellableBag)
    }
    
    private func handleImageOutput(_ output: ViewModel.Output) {
        output.imageOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageItemList in
                guard let self = self else { return }
                if !imageItemList.isEmpty {
                    imageWarn(enable: false)
                }
                self.imageUploadView.setImageItem(items: imageItemList)
            }
            .store(in: &cancellableBag)
    }
    
    private func imageWarn(enable: Bool) {
        let alpha: CGFloat = enable ? 1 : 0
        imageWarningLabel.alpha = alpha
    }
    
}

@objc
private extension PostCreateViewController {
    
    func close(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    func post(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ""
        guard var priceText = postCreatePriceView.priceTextField.text else { return }
        priceText = priceText.replacingOccurrences(of: ",", with: "")
        var detailText = postCreateDetailView.detailTextView.text ?? ""
        if detailText == "설명을 입력하세요." {
            detailText = ""
        }
        postInfoPublisher.send(
            PostModifyInfo(
                title: postCreateTitleView.titleTextField.text ?? "",
                startTime: postCreateStartTimeView.timeString,
                endTime: postCreateEndTimeView.timeString,
                price: priceText,
                detail: detailText
            )
        )
    }
    
    func hideKeyboard(_ sender: UIBarButtonItem) {
        view.endEditing(true)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo as NSDictionary?,
              var keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        keyboardFrame = view.convert(keyboardFrame, from: nil)
        NSLayoutConstraint.deactivate([scrollViewBottomConstraint])
        scrollViewBottomConstraint = scrollView
            .bottomAnchor
            .constraint(
                equalTo: view.bottomAnchor,
                constant: -keyboardFrame.height
            )
        NSLayoutConstraint.activate([scrollViewBottomConstraint])
    }
    
    func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo as NSDictionary?,
              var keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        keyboardFrame = view.convert(keyboardFrame, from: nil)
        NSLayoutConstraint.deactivate([scrollViewBottomConstraint])
        scrollViewBottomConstraint = scrollView
            .bottomAnchor
            .constraint(
                equalTo: postButtonView.topAnchor,
                constant: 0
            )
        NSLayoutConstraint.activate([scrollViewBottomConstraint])
    }
    
}

private extension PostCreateViewController {
    
    func setUpNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func configureUI() {
        view.addSubview(postButtonView)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        postButtonView.addSubview(postButton)
        
        if !viewModel.isRequest {
            stackView.addArrangedSubview(imageUploadView)
            stackView.addArrangedSubview(imageWarningLabel)
        }
        stackView.addArrangedSubview(postCreateTitleView)
        stackView.addArrangedSubview(postCreateStartTimeView)
        stackView.addArrangedSubview(postCreateEndTimeView)
        
        if !viewModel.isRequest {
            stackView.addArrangedSubview(postCreatePriceView)
        }
        
        stackView.addArrangedSubview(postCreateDetailView)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            postButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            postButtonView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollViewBottomConstraint
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -25),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            postButton.topAnchor.constraint(equalTo: postButtonView.topAnchor, constant: 18),
            postButton.leadingAnchor.constraint(equalTo: postButtonView.leadingAnchor, constant: 16),
            postButton.trailingAnchor.constraint(equalTo: postButtonView.trailingAnchor, constant: -16),
            postButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            postCreateTitleView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50),
            postCreateStartTimeView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50),
            postCreateEndTimeView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50),
            postCreateDetailView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50)
        ])
        
        if !viewModel.isRequest {
            NSLayoutConstraint.activate([
                postCreatePriceView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50)
            ])
        }
    }
    
    func configureNavigation() {
        let titleLabel = UILabel()
        if viewModel.isRequest {
            if viewModel.isEdit {
                titleLabel.setTitle("대여 요청 등록 편집")
            } else {
                titleLabel.setTitle("대여 요청 등록")
            }
        } else {
            if viewModel.isEdit {
                titleLabel.setTitle("대여 등록 편집")
            } else {
                titleLabel.setTitle("대여 등록")
            }
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        let close = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(close), symbolName: .xmark
        )
        self.navigationItem.rightBarButtonItems = [close]
        self.navigationItem.backButtonDisplayMode = .minimal
    }
    
}

extension PostCreateViewController: PHPickerViewControllerDelegate {
    
    private var configuration: PHPickerConfiguration {
        var config = PHPickerConfiguration()
        config.selectionLimit = Constant.maxImageCount - viewModel.imagesCount
        config.filter = .images
        config.selection = .ordered
        
        return config
    }
    
    private func presentPHPickerViewController() {
        guard configuration.selectionLimit > 0 else {
            showImageMaximumAlert()
            return
        }
        let pickerVC = PHPickerViewController(configuration: configuration)
        pickerVC.delegate = self
        self.present(pickerVC, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProviders = results.map(\.itemProvider)
        let dispatchGroup = DispatchGroup()
        var imageData = [Data]()
        itemProviders.forEach { itemProvider in
            dispatchGroup.enter()
            itemProvider.getImageData { data in
                if let data {
                    imageData.append(data)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.selectedImagePublisher.send(imageData)
        }
        picker.dismiss(animated: true)
    }
    
    private func showImageMaximumAlert() {
        let alert = UIAlertController(title: "이미지는 최대 12장 첨부 가능합니다!", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "확인", style: .cancel))
        self.present(alert, animated: true)
    }
    
}
