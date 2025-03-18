//
//  MusicCell.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//

import UIKit

class MusicCell: UITableViewCell {
    
    public lazy var musicIndexLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
        label.textColor = .white
        label.font = UIFont(name: "PingFangSC-Medium", size: 15)
        return label
    }()
    
    public lazy var musicNameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 50, y: 10, width: 300, height: 20))
        label.textColor = .systemBlue
        label.font = UIFont(name: "PingFangSC-Medium", size: 20)
        return label
    }()
    
    public var singerLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 50, y: 40, width: 200, height: 20))
        label.textColor = .white
        label.font = UIFont(name: "PingFangSC-Medium", size: 15)
        return label
    }()
    
    public var durationLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 270, y: 40, width: 50, height: 20))
        label.textColor = .white
        return label
    }()
    
    /// 按钮存在bug
    public var favoriteButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 270, y: 10, width: 10, height: 10))
        button.setImage(UIImage(named: "star"), for: .normal)
        button.setImage(UIImage(named: "star.fill"), for: .selected)
        button.addTarget(MusicCell.self, action: #selector(toggleFavorite), for: .touchUpInside)
        return button
    }()
    public var isFavorite: Bool = false
    
    public var musicPhoto: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 350, y: 0, width: 80, height: 80))
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    /// “喜欢”状态变化时的闭包回调
    public var onFavoriteToggle: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews([musicNameLabel, musicIndexLabel, singerLabel, durationLabel, musicPhoto])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func toggleFavorite() {
        isFavorite.toggle()
        onFavoriteToggle?(isFavorite)
    }

}
