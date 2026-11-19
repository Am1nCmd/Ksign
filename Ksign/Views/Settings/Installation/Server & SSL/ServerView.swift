//
//  ServerView.swift
//  Feather
//
//  Created by samara on 6.05.2025.
//

import SwiftUI
import NimbleViews

struct ServerView: View {
	var body: some View {
		Section {
			LabeledContent(String.localized("Engine"), value: "AmS1gn ITMS (Cloudflare)")
			LabeledContent(String.localized("Host"), value: "itms.ams1gn.id")
			LabeledContent(String.localized("Status"), value: String.localized("Active"))
		} footer: {
			Text("Uses first-party AmS1gn Cloudflare ITMS service to install applications directly on-device. No SSL certificates or third-party servers required.")
		}
	}
}
