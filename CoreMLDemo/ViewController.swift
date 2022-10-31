//
//  ViewController.swift
//  CoreMLDemo
//
//  Created by 강대민 on 2022/11/01.
//

import UIKit
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        //실행시 화면 높이를 오버플로우하지 않기 바라는 마음에 기본 시스템이미지 사용.
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "이미지를 선택해주세요."
        label.numberOfLines = 0
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        [imageView, label]
            .forEach { view.addSubview($0) }
        
        //이미지 선택을 위한 제스처
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        //기본 요구하는 탭 수를 정해준다. 더블탭이면 2
        tap.numberOfTapsRequired = 1
        
        //사용자 상호작용을 활성화해야 제스처가 된다
        imageView.isUserInteractionEnabled = true
        
        //이미지뷰를 누르면 이미지 선택화면으로 넘어감.
        imageView.addGestureRecognizer(tap)
        
        print("실행됐는지.")
    }
    
    //셀렉터 함수
    @objc func didTapImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = CGRect(x: 20, y: view.safeAreaInsets.top,
                                 width: view.frame.size.width-40,
                                 height: view.frame.size.width-40)
        
        label.frame = CGRect(x: 20, y: view.safeAreaInsets.top+(view.frame.size.width-40)+10,
                             width: view.frame.size.width-40,
                             height: 100)
    }
    
    
    private func analyzeImage(image: UIImage?) {
//        //이미지 크기를 조정하길 원한다. Extensions.swift 에 있는 resize 함수를 불러와 크기를 고정시켜 정해준다.
//        let resized = image?.resize(size: CGSize(width: 224, height: 224))
//        //pixel에서 이미지의 버퍼를 알고싶고 그 이미지에서 버퍼를 제거하고 크기를 조정한다.
//        let buffer = resized?.getCVPixelBuffer()
        //위의 방법은 아래서 사용할시에 옵셔널값에 의해 에러가 발생하기 때문에 가드처리한다.
        guard let buffer = image?.resize(size: CGSize(width: 224, height: 224))?
                .getCVPixelBuffer() else {
                    return
                }
        
        
        //이미지는 항상 예외가 발생 할 수 있기 떄문에..
        do {
            //GoogLe -> 구글렌즈!?
            //머신러닝 모델을 컨피규어 해주고
            let config = MLModelConfiguration()
            //구글 넥플레이스 모델에 config를 등록해준다.
            let model = try GoogLeNetPlaces(configuration: config)
            //모델을 생성한 후에 모델에 대한 입력을 생성해야한다.
            //입력은 기본적으로 여기선 google렌즈가 될것이다.
            //블럭을 보면 알다싶이 input에서 원하는 매개변수가 픽셀 버퍼이므로 강의에서 제공하는 버퍼를 우선 사용할것이다.
//            let input = GoogLeNetPlacesInput(sceneImage: <#T##CVPixelBuffer#>)
            let input = GoogLeNetPlacesInput(sceneImage: buffer)
            
            //우리가 얻고자하는 결과 output
            //구조화된 인터페이스를 사용하여 예측을 하는 것
            //prediction의 뜻은 '예측'이라는 뜻 이것은 입력을 요구한다.
            let output = try model.prediction(input: input)
            //분류된 장면을 원하고 텍스트를 입력하면 원하는 텍스트를 출력
            let text = output.sceneLabel
            label.text = text
            
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    //image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //취소시
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        //인포키를 얻고 오리지날이미지를 얻을것이다.
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        //이미지를 등록
        imageView.image = image
        //이미지를 분석
        analyzeImage(image: image)
    }
    
}

