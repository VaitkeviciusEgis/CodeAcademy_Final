//
//  SendMoneyButtonTests.swift
//  CodeAcademy_FinalTests
//
//  Created by Egidijus Vaitkevičius on 2023-05-03.
//

import XCTest
@testable import CodeAcademy_Final

final class SendMoneyButtonTests: XCTestCase {

    func testSendMoneyButtonEnabled() {
     
        let viewController = TransferViewController()
        let sendMoneyButton = UIButton()
        let enterAmountTextField = UITextField()
        let recipientPhoneNumberTextField = UITextField()
        let commentTextField = UITextField()



        enterAmountTextField.text = ""
        recipientPhoneNumberTextField.text = ""
        commentTextField.text = ""


        XCTAssertFalse(sendMoneyButton.isEnabled, "Send Money button should be disabled if all textfields are empty")


    }

}
