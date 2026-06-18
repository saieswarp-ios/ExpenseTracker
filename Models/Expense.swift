//
//  Expense.swift
//  ExpenseTracker
//
//  Created by IOS DEV on 18/06/26.
//
import Foundation

struct Expense: Codable {

    let title: String
    let amount: Double
    let category: String
    let date: Date
}
