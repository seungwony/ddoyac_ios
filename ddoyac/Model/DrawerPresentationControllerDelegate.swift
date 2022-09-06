//
//  DrawerPresentationControllerDelegate.swift
//  ddoyac
//
//  Created by SEUNGWON YANG on 2021/05/18.
//
import Foundation

public protocol DrawerPresentationControllerDelegate: class {
    func drawerMovedTo(position: DraweSnapPoint)
}

public enum DraweSnapPoint {
    case top
    case middle
    case close
}
