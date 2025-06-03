//
//  ViewController.swift
//  ShareMyLocationBySMS
//
//  Created by Yasin Cetin on 12.05.2025.
//

import UIKit
import ContactsUI
import CoreLocation
import MessageUI


class ViewController: UIViewController, CNContactPickerDelegate, CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate {

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var selectedPhoneNumber: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Buton oluştur
        let button = UIButton(type: .system)
        button.setTitle("Kişi Seç ve Konum Gönder", for: .normal)
        button.addTarget(self, action: #selector(selectContact), for: .touchUpInside)
        button.frame = CGRect(x: 40, y: 200, width: view.frame.width - 80, height: 50)
        view.addSubview(button)

        // Konum izni al
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    @objc func selectContact() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        present(contactPicker, animated: true, completion: nil)
    }

    // Kişi seçildiğinde
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        guard let phoneNumber = contact.phoneNumbers.first?.value.stringValue else {
            print("Telefon numarası bulunamadı")
            return
        }
        selectedPhoneNumber = phoneNumber

        // Konumu almaya başla
        locationManager.startUpdatingLocation()
    }

    // Konum güncellendiğinde
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        guard let location = locations.last else { return }
        currentLocation = location

        sendSMS()
    }

    // SMS gönderme
    func sendSMS() {
        guard MFMessageComposeViewController.canSendText(),
              let phoneNumber = selectedPhoneNumber,
              let location = currentLocation else {
            print("SMS gönderilemedi")
            return
        }

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let message = "Benim konumum: https://maps.google.com/?q=\(lat),\(lon)"

        let messageVC = MFMessageComposeViewController()
        messageVC.body = message
        messageVC.recipients = [phoneNumber]
        messageVC.messageComposeDelegate = self

        present(messageVC, animated: true, completion: nil)
    }

    // SMS gönderimi tamamlandığında
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

