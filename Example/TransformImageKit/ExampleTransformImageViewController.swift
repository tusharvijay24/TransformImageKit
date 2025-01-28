//
//  ExampleTransformImageViewController.swift
//  TransformImageKit
//
//  Created by tusharvijay24 on 01/28/2025.
//  Copyright (c) 2025 tusharvijay24. All rights reserved.
//


import UIKit
import PhotosUI
import QuickLook
import TransformImageKit

class ExampleTransformImageViewController: UIViewController {
    
    @IBOutlet weak var txtPixelWidth: UITextField!
    @IBOutlet weak var txtPixelHeight: UITextField!
    @IBOutlet weak var txtCompressionQuality: UITextField!
    @IBOutlet weak var txtOutputFormat: UITextField!
    
    let imageManager = TransformImageManager()
    let formats = TransformImageFormatEnum.allCases
    var selectedFormat: TransformImageFormatEnum? = .png
    private var formatPicker: UIPickerView!
    private var activityIndicator: UIActivityIndicatorView!
    
    var selectedImageURLs: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupFormatPicker()
        setupActivityIndicator()
    }
    
    private func setupFormatPicker() {
        formatPicker = UIPickerView()
        formatPicker.delegate = self
        formatPicker.dataSource = self
        txtOutputFormat.inputView = formatPicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePickingFormat))
        toolbar.setItems([doneButton], animated: true)
        txtOutputFormat.inputAccessoryView = toolbar
    
        if let defaultIndex = formats.firstIndex(of: selectedFormat ?? .png) {
            formatPicker.selectRow(defaultIndex, inComponent: 0, animated: false)
            txtOutputFormat.text = formats[defaultIndex].rawValue
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .large)
        activityIndicator.color = .blue
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    @objc private func donePickingFormat() {
        txtOutputFormat.resignFirstResponder()
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5 
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    
    @IBAction func didTapConvertImages(_ sender: UIButton) {
        guard !selectedImageURLs.isEmpty else {
            showAlert(title: "No Images Selected", message: "Please select images to convert.")
            return
        }
        
        let pixelWidth = Int(txtPixelWidth.text ?? "")
        let pixelHeight = Int(txtPixelHeight.text ?? "")
        let compressionQuality = Double(txtCompressionQuality.text ?? "") ?? 1.0
        guard let selectedFormat = selectedFormat else { return }
        
        activityIndicator.startAnimating()
        
        imageManager.convertAndZipImages(
            imagePaths: selectedImageURLs,
            format: selectedFormat,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            compressionQuality: compressionQuality
        ) { [weak self] result in
            self?.handleConversionResult(result)
        }
    }
    
    private func handleConversionResult(_ result: Result<URL, Error>) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let archiveURL):
                let activityVC = UIActivityViewController(activityItems: [archiveURL], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            case .failure(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension ExampleTransformImageViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        if results.count > 5 {
            showAlert(title: "Selection Limit Exceeded", message: "You can select a maximum of 5 images.")
            return
        }

        selectedImageURLs.removeAll()
        
        let group = DispatchGroup()
        results.forEach { result in
            group.enter()
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
                defer { group.leave() }
                guard let self = self, let url = url else { return }
                
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".\(TransformImageFormatEnum.png.fileExtension)")
                do {
                    try FileManager.default.copyItem(at: url, to: tempURL)
                    self.selectedImageURLs.append(tempURL)
                } catch {
                    print("Error copying image: \(error)")
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.showPreview()
        }
    }

    
    private func showPreview() {
        guard !selectedImageURLs.isEmpty else { return }
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true, completion: nil)
    }
}

extension ExampleTransformImageViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return formats.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return formats[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFormat = formats[row]
        txtOutputFormat.text = selectedFormat?.rawValue
    }
}

extension ExampleTransformImageViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return selectedImageURLs.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return selectedImageURLs[index] as QLPreviewItem
    }
}
