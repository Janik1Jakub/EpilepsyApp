//MIT license
//
//Copyright (c) 2021 Richard Topchii
//
//Permission is hereby granted, free of charge, to any person obtaining
//a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including
//without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to
//permit persons to whom the Software is furnished to do so, subject to
//the following conditions:
//
//The above copyright notice and this permission notice shall be
//included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import CalendarKit
import EventKit
import EventKitUI

final class CalendarViewController: DayViewController, EKEventEditViewDelegate
{
    private let eventStore = EKEventStore()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Calendar"
        requestAccessToCalendar()
        subscribeToNotifications()
    }

    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: eventStore)
    }
    
    private func requestAccessToCalendar()
    {
        eventStore.requestAccess(to: .event) { granted, error in
        }
    }
    
    @objc private func storeChanged(_ notification: Notification)
    {
        reloadData()
    }
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor]
    {
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let eventKitEvents = eventStore.events(matching: predicate)
        let calendarKitEvents = eventKitEvents.map(EventViewController.init)
        return calendarKitEvents
    }
    
    override func dayViewDidSelectEventView(_ eventView: EventView)
    {
        guard let ckEvent = eventView.descriptor as? EventViewController else
        {
            return
        }
        presentDetailViewForEvent(ckEvent.ekEvent)
    }
    
    private func presentDetailViewForEvent(_ ekEvent: EKEvent)
    {
        let eventController = EKEventViewController()
        eventController.event = ekEvent
        eventController.allowsCalendarPreview = true
        eventController.allowsEditing = true
        navigationController?.pushViewController(eventController,
                                                 animated: true)
    }
    
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date)
    {
        endEventEditing()
        let newEventViewController = createNewEvent(at: date)
        create(event: newEventViewController, animated: true)
    }
    
    private func createNewEvent(at date: Date) -> EventViewController
    {
        let newEKEvent = EKEvent(eventStore: eventStore)
        newEKEvent.calendar = eventStore.defaultCalendarForNewEvents
        var components = DateComponents()
        components.hour = 1
        let newEKWrapper = EventViewController(eventKitEvent: newEKEvent)
        newEKWrapper.editedEvent = newEKWrapper
        let endDate = calendar.date(byAdding: components, to: date)
        newEKEvent.startDate = date
        newEKEvent.endDate = endDate
        newEKEvent.title = "New event"
        return newEKWrapper
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView)
    {
        guard let descriptor = eventView.descriptor as? EventViewController else
        {
            return
        }
        endEventEditing()
        beginEditing(event: descriptor,
                     animated: true)
    }
    
    override func dayView(dayView: DayView, didUpdate event: EventDescriptor)
    {
        guard let editingEvent = event as? EventViewController else { return }
        if let originalEvent = event.editedEvent
        {
            editingEvent.commitEditing()
            
            if originalEvent === editingEvent
            {
                presentEditingViewForEvent(editingEvent.ekEvent)
            } else {
                try! eventStore.save(editingEvent.ekEvent, span: .thisEvent)
            }
        }
        reloadData()
    }
    
    private func presentEditingViewForEvent(_ ekEvent: EKEvent)
    {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = ekEvent
        eventEditViewController.eventStore = eventStore
        eventEditViewController.editViewDelegate = self
        present(eventEditViewController, animated: true, completion: nil)
    }
    
    override func dayView(dayView: DayView, didTapTimelineAt date: Date)
    {
        endEventEditing()
    }
    
    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction)
    {
        endEventEditing()
        reloadData()
        controller.dismiss(animated: true, completion: nil)
    }
}
