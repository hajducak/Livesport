//
//  CounterFeatureTests.swift
//  LivesportTests

import ComposableArchitecture
import XCTest

@testable import Livesport

@MainActor
final class ContactsFeatureTests: XCTestCase {
    
    func testAddFlow() async {
        let store = TestStore(initialState: ContactsFeature.State()) {
            ContactsFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.addButtonTapped) {
            $0.destination = .addContact(
                AddContactFeature.State(
                    contact: Contact(id: UUID(0), name: "")
                )
            )
        }
        // Emulate the user typing into the name text field of the contact. The trailing closure is where we can assert on how state changed after sending the action.
        await store.send(.destination(.presented(.addContact(.setName("Blob Jr."))))) {
            // Assert on how state changed by mutating the destination through the addContact case of the destination enum.
            $0.$destination[case: /ContactsFeature.Destination.State.addContact]?.contact.name = "Blob Jr."
        }
        // Emulate the user tapping the “Save” button in the “Add Contact” feature.
        await store.send(.destination(.presented(.addContact(.saveButtonTapped))))
        // Emulate the delegate action saveContact being received by the test store. This action is sent from the AddContactFeature when the “Save” button is tapped.
        await store.receive(
            .destination(
                .presented(.addContact(.delegate(.saveContact(Contact(id: UUID(0), name: "Blob Jr.")))))
            )
        ) {
            // Assert that when the saveContact delegate action is received that state mutates by adding a contact to the array.
            $0.contacts = [
                Contact(id: UUID(0), name: "Blob Jr.")
            ]
        }
        // Finally assert that the test store receives a PresentationAction.dismiss action, which causes the “Add Contact” feature to be dismissed.
        await store.receive(.destination(.dismiss)) {
            $0.destination = nil
        }
    }
    
    func testAddFlow_NonExhaustive() async {
        let store = TestStore(initialState: ContactsFeature.State()) {
            ContactsFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off
        await store.send(.addButtonTapped)
        await store.send(.destination(.presented(.addContact(.setName("Blob Jr.")))))
        await store.send(.destination(.presented(.addContact(.saveButtonTapped))))
        await store.skipReceivedActions()
        store.assert {
            $0.contacts = [
                Contact(id: UUID(0), name: "Blob Jr.")
            ]
            $0.destination = nil
        }
    } // That’s all it takes to write a very high level test covering the full user flow of adding a new contact to the list. We don’t need to assert on all of the nitty gritty details in the child feature, and instead can just assert that the contact was indeed added after the user completed their steps.
    
    func testDeleteContact() async {
        let store = TestStore(
            initialState: ContactsFeature.State(
                contacts: [
                    Contact(id: UUID(0), name: "Blob"),
                    Contact(id: UUID(1), name: "Blob Jr."),
                ]
            )
        ) {
            ContactsFeature()
        }

        await store.send(.deleteButtonTapped(id: UUID(1))) {
            $0.destination = .alert(.deleteConfirmation(id: UUID(1)))
        }
        await store.send(.destination(.presented(.alert(.confirmDeletion(id: UUID(1)))))) {
            $0.contacts.remove(id: UUID(1))
            $0.destination = nil
        }
    }
}
