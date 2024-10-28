//
//  TasksWidgetBundle.swift
//  TasksWidget
//
//  Created by Prudhvi Suraaj on 21/10/24.
//

import WidgetKit
import SwiftUI

@main
struct TasksWidgetBundle: WidgetBundle {
    var body: some Widget {
        TasksWidget()
        TasksWidgetControl()
    }
}
