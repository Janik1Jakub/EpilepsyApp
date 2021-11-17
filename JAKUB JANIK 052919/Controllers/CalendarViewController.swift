//
//  CallendarViewController.swift
//  PRACA INŻYNIERSKA
//
//  Created by Jakub Janik on 25/06/2021.
//

import Foundation
import UIKit
import CalendarKit
import EventKit

class CalendarViewController: DayViewController
{
    private let eventStore = EKEventStore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Calendar"
        requestAccessToCalendar()
    }
    
    func requestAccessToCalendar()
    {
        eventStore.requestAccess(to: .event) {
            success, error in
        }
    }
    
    //events


    override func eventsForDate(_ date: Date) -> [EventDescriptor]
    {
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let eventKitEvents = eventStore.events(matching: predicate)
        
        let calendarKitEvents = eventKitEvents.map {ekEvent -> Event in
            let ckEvent = Event()
            ckEvent.startDate = ekEvent.startDate
            ckEvent.endDate = ekEvent.endDate
            ckEvent.isAllDay = ekEvent.isAllDay
            ckEvent.text = ekEvent.title
            if let eventColor = ekEvent.calendar.cgColor{
                ckEvent.color = UIColor(cgColor: eventColor)
            }
            return ckEvent
        }
        return calendarKitEvents
        }

}
