//
//  ViewController.swift
//  CalendarApp
//
//  Created by 유현재 on 27/04/2020.
//  Copyright © 2020 유현재. All rights reserved.
//

import UIKit

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var yearMonthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let now = Date()
    var cal = Calendar.current
    let dateFormatter = DateFormatter()
    var components = DateComponents()
    var weeks: [String] = ["日", "月", "火", "水", "木", "金", "土"]
    var days: [String] = []
    var daysCountInMonth = 0
    var weekdayAdding = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }
   
    private func initView() {
        self.initCollection()
        
        dateFormatter.dateFormat = "yyyy年M月"
        components.year = cal.component(.year, from: now)
        components.month = cal.component(.month, from: now)
        components.day = 1
        self.calculation()
    }
    
    private func initCollection() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "CalendarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendarCell")
        self.collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:))))
    }
    
    private func calculation() {
        let firstDayOfMonth = cal.date(from: components)
        let firstWeekday = cal.component(.weekday, from: firstDayOfMonth!) // 1~7 1日~7土
        daysCountInMonth = cal.range(of: .day, in: .month, for: firstDayOfMonth!)!.count
        weekdayAdding = 2 - firstWeekday // 4水　前3日は空く必要があるので2から減算し、-2 -1 0 のように0より小さい数字を作る
        
        self.yearMonthLabel.text = dateFormatter.string(from: firstDayOfMonth!)
        
        self.days.removeAll()
        for day in weekdayAdding...daysCountInMonth {
            if day < 1 {
                self.days.append("")
            } else {
                self.days.append(String(day))
            }
        }
    }
    
    
    @objc func handleLongPressGesture(_ sender: UIGestureRecognizer) {
        let location = sender.location(in: self.collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
        let item = days[indexPath.row]

        let alert = UIAlertController(title: "D-day 설정", message: "\(item)을 D-day로 설정하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (_) in
            self.collectionView.reloadItems(at: [indexPath])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
       
    
    @IBAction func didTappedPrevButton(_ sender: UIButton) {
        components.month = components.month! - 1
        self.calculation()
        self.collectionView.reloadData()
    }
    
    @IBAction func didTappedNextButton(_ sender: UIButton) {
        components.month = components.month! + 1
        self.calculation()
        self.collectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 7
        default:
            return self.days.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell
        
        switch indexPath.section {
        case 0:
            cell.dateLabel.text = weeks[indexPath.row]
        default:
            cell.dateLabel.text = days[indexPath.row]
        }
        
        if indexPath.row % 7 == 0 {
            cell.dateLabel.textColor = .red
        } else if indexPath.row % 7 == 6 {
            cell.dateLabel.textColor = .blue
        } else {
            cell.dateLabel.textColor = .black
        }

        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let myBoundSize: CGFloat = UIScreen.main.bounds.size.width
        let cellSize : CGFloat = myBoundSize / 9
        return CGSize(width: cellSize, height: cellSize)
    }
}
