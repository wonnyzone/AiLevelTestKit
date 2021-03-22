//
//  ALTCouponListHeaderView.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/16.
//

import UIKit

protocol ALTCouponListHeaderViewDelegate {
    func couponListHeaderView(_ headerView: ALTCouponListHeaderView, didRequestToRegister coupon: String) -> Bool
    func couponListHeaderView(_ headerView: ALTCouponListHeaderView, didChange segment: ALTCouponListHeaderView.Segment)
}

class ALTCouponListHeaderView: UIView {
    enum Segment: Int {
        case available = 0
        case unavailable = 1
    }
    
    class var height: CGFloat { return 285.optimized }
    
    private let _buttonRegister = UIButton()
    let textfieldCoupon = UITextField()
    
    private let _buttonAvailableCoupons = UIButton()
    private let _buttonUnavailableCoupons = UIButton()
    
    var delegate: ALTCouponListHeaderViewDelegate?
    
    var selectedCategory: Segment {
        return _selectedCategory
    }
    private var _selectedCategory = Segment.available
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        var backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColourKit.Code.Hex121212
        self.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        backView.heightAnchor.constraint(equalToConstant: 139.optimized).isActive = true
        
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "쿠폰 등록"
        label.textColor = ColourKit.Code.HexFFFFFF
        label.font = UIFont.systemFont(ofSize: 18.optimized, weight: .regular)
        backView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: backView.topAnchor, constant: 27.optimized).isActive = true
        label.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20.optimized).isActive = true
        
        _buttonRegister.translatesAutoresizingMaskIntoConstraints = false
        _buttonRegister.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Static.HexFA4175), for: .normal)
        _buttonRegister.setTitle("등록하기", for: .normal)
        _buttonRegister.setTitleColor(.white, for: .normal)
        _buttonRegister.titleLabel?.font = UIFont.systemFont(ofSize: 13.optimized, weight: .regular)
        _buttonRegister.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        backView.addSubview(_buttonRegister)

        _buttonRegister.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -27.optimized).isActive = true
        _buttonRegister.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16.optimized).isActive = true
        _buttonRegister.widthAnchor.constraint(equalToConstant: 110.optimized).isActive = true
        _buttonRegister.heightAnchor.constraint(equalToConstant: 52.optimized).isActive = true

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = ColourKit.Code.HexFFFFFF
        backView.addSubview(contentView)

        contentView.topAnchor.constraint(equalTo: _buttonRegister.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: _buttonRegister.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 16.optimized).isActive = true
        contentView.trailingAnchor.constraint(equalTo: _buttonRegister.leadingAnchor).isActive = true
        
        textfieldCoupon.translatesAutoresizingMaskIntoConstraints = false
        textfieldCoupon.backgroundColor = .clear
        textfieldCoupon.placeholder = "쿠폰 번호 입력"
        textfieldCoupon.textColor = ColourKit.Code.Hex000000
        textfieldCoupon.font = UIFont.systemFont(ofSize: 16.optimized, weight: .regular)
        textfieldCoupon.clearButtonMode = .always
        textfieldCoupon.borderStyle = .none
        contentView.addSubview(textfieldCoupon)

        textfieldCoupon.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textfieldCoupon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        textfieldCoupon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.optimized).isActive = true
        textfieldCoupon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.optimized).isActive = true
        
        let bottomAnchor = backView.bottomAnchor

        backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColourKit.Code.Hex121212
        self.addSubview(backView)

        backView.topAnchor.constraint(equalTo: bottomAnchor, constant: 21.optimized).isActive = true
        backView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "쿠폰 리스트"
        label.textColor = ColourKit.Code.HexFFFFFF
        label.font = UIFont.systemFont(ofSize: 18.optimized, weight: .regular)
        backView.addSubview(label)

        label.topAnchor.constraint(equalTo: backView.topAnchor, constant: 30.optimized).isActive = true
        label.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20.optimized).isActive = true

        _buttonAvailableCoupons.translatesAutoresizingMaskIntoConstraints = false
        _buttonAvailableCoupons.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex121212), for: .normal)
        _buttonAvailableCoupons.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex555555), for: .selected)
        _buttonAvailableCoupons.setTitle("사용 가능한 쿠폰", for: .normal)
        _buttonAvailableCoupons.setTitleColor(ColourKit.Code.HexCCCCCC, for: .normal)
        _buttonAvailableCoupons.setTitleColor(ColourKit.Code.HexEEEEEE, for: .selected)
        _buttonAvailableCoupons.titleLabel?.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        _buttonAvailableCoupons.isSelected = _selectedCategory == .available
        _buttonAvailableCoupons.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _buttonAvailableCoupons.layer.borderColor = ColourKit.Code.Hex555555.cgColor
        _buttonAvailableCoupons.layer.borderWidth = 1 / UIScreen.main.scale
        backView.addSubview(_buttonAvailableCoupons)

        _buttonAvailableCoupons.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 18.optimized).isActive = true
        _buttonAvailableCoupons.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 16.optimized).isActive = true
        _buttonAvailableCoupons.trailingAnchor.constraint(equalTo: backView.centerXAnchor).isActive = true
        _buttonAvailableCoupons.heightAnchor.constraint(equalToConstant: 40.optimized).isActive = true

        _buttonUnavailableCoupons.translatesAutoresizingMaskIntoConstraints = false
        _buttonUnavailableCoupons.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex121212), for: .normal)
        _buttonUnavailableCoupons.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex555555), for: .selected)
        _buttonUnavailableCoupons.setTitle("사용 불가능한 쿠폰", for: .normal)
        _buttonUnavailableCoupons.setTitleColor(ColourKit.Code.HexCCCCCC, for: .normal)
        _buttonUnavailableCoupons.setTitleColor(ColourKit.Code.HexEEEEEE, for: .selected)
        _buttonUnavailableCoupons.titleLabel?.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        _buttonUnavailableCoupons.isSelected = _selectedCategory == .unavailable
        _buttonUnavailableCoupons.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _buttonUnavailableCoupons.layer.borderColor = ColourKit.Code.Hex555555.cgColor
        _buttonUnavailableCoupons.layer.borderWidth = 1 / UIScreen.main.scale
        backView.addSubview(_buttonUnavailableCoupons)

        _buttonUnavailableCoupons.topAnchor.constraint(equalTo: _buttonAvailableCoupons.topAnchor).isActive = true
        _buttonUnavailableCoupons.bottomAnchor.constraint(equalTo: _buttonAvailableCoupons.bottomAnchor).isActive = true
        _buttonUnavailableCoupons.leadingAnchor.constraint(equalTo: backView.centerXAnchor).isActive = true
        _buttonUnavailableCoupons.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16.optimized).isActive = true

        self.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func pressedButton(_ button: UIButton) {
        switch button {
        case _buttonRegister:
            guard let couponCode = textfieldCoupon.text, couponCode.count > 0 else { break }
            
            let canRegister = delegate?.couponListHeaderView(self, didRequestToRegister: couponCode) ?? false
            
            guard canRegister else { break }
            textfieldCoupon.text = nil
            break
            
        case _buttonAvailableCoupons, _buttonUnavailableCoupons:
            var targetCategory = Segment.unavailable
            if button == _buttonAvailableCoupons {
                targetCategory = .available
            }
            
            guard _selectedCategory != targetCategory else { break }
            
            _selectedCategory = targetCategory
            
            _buttonAvailableCoupons.isSelected = button == _buttonAvailableCoupons
            _buttonUnavailableCoupons.isSelected = button == _buttonUnavailableCoupons
            
            delegate?.couponListHeaderView(self, didChange: targetCategory)
            break
            
        default:
            break
        }
    }
}
