//
//  Date.Quickstart.swift
//  Quickstart
//
//  Created by Jaesung Lee on 2021/12/19.
//

import Foundation

/// The extension methods are also provided by `SendBirdUIKit` version *2.2.0 or later*.
extension Date {
    /// The `Date` value represents the time interval since 1970 with the time stamp.
    /// Please refer to `Date sbu_from(_:)` from `SendBirdUIKit` version *2.2.0 or later*.
    static public func from(_ baseTimestamp: Int64) -> Date {
        let timestampString = String(format: "%lld", baseTimestamp)
        let timeInterval = timestampString.count == 10
        ? TimeInterval(baseTimestamp)
        : TimeInterval(Double(baseTimestamp) / 1000.0)
        return Date(timeIntervalSince1970: timeInterval)
    }
}
