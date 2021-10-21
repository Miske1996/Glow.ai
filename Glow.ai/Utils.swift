//
//  Utils.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 10/09/2021.
//

import SwiftUI


extension Color {
    static let oldPrimaryColor = Color(UIColor.systemIndigo)
    static let newPrimaryColor = Color("PrimaryColor")
}

extension View {
    func customButton() -> ModifiedContent<Self, ButtonModifier> {
        return modifier(ButtonModifier())
    }
}


struct ButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.custom("TitilliumWeb-Bold", size: 24))
            .foregroundColor(.white)
            .padding()
            .frame(width: UIScreen.main.bounds.width - 30, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 8, style:   .circular).fill(Color.newPrimaryColor))
            .padding(.bottom, 8)
    }
}
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

public struct NeonDefaultValues {
    public static let lineWidth: CGFloat = 16
    public static let cornerRadius: CGFloat = 16
    public static let shadowRadius: CGFloat = 24
}

public struct NeonCircle: ViewModifier {
    public let color: Color
    public var lineWidth: CGFloat = NeonDefaultValues.lineWidth
    public var shadowRadius: CGFloat = NeonDefaultValues.shadowRadius
    
    public init(color: Color,
                lineWidth: CGFloat? = nil,
                cornerRadius: CGFloat? = nil,
                shadowRadius: CGFloat? = nil) {
        self.color = color
        
        if let width = lineWidth {
            self.lineWidth = width
        }
        
        if let radius = shadowRadius {
            self.shadowRadius = radius
        }
    }
    
    public func body(content: Content) -> some View {
        content
            .padding()
            .background(
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .foregroundColor(color)
                    .shadow(color: color,
                            radius: shadowRadius)
                
            )
    }
}

enum KeychainError: Error {
  case secCallFailed(OSStatus)
  case notFound
  case badData
  case archiveFailure(Error)
}

protocol Keychain {
  associatedtype DataType: Codable

  var account: String { get set }
  var service: String { get set }

  func remove() throws
  func retrieve() throws -> DataType
  func store(_ data: DataType) throws
}

extension Keychain {
  func remove() throws {
    let status = SecItemDelete(keychainQuery() as CFDictionary)
    guard status == noErr || status == errSecItemNotFound else {
      throw KeychainError.secCallFailed(status)
    }
  }

  func retrieve() throws -> DataType {
    var query = keychainQuery()
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    query[kSecReturnAttributes as String] = kCFBooleanTrue
    query[kSecReturnData as String] = kCFBooleanTrue

    var result: AnyObject?
    let status = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }

    guard status != errSecItemNotFound else { throw KeychainError.notFound }
    guard status == noErr else { throw KeychainError.secCallFailed(status) }

    do {
      guard
        let dict = result as? [String: AnyObject],
        let data = dict[kSecAttrGeneric as String] as? Data,
        let userData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? DataType
        else {
          throw KeychainError.badData
      }

      return userData
    } catch {
      throw KeychainError.archiveFailure(error)
    }
  }

  func store(_ data: DataType) throws {
    var query = keychainQuery()

    let archived: AnyObject
    do {
      archived = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true) as AnyObject
    } catch {
      throw KeychainError.archiveFailure(error)
    }

    let status: OSStatus
    do {
      // If doesn't already exist, this will throw a KeychainError.notFound,
      // causing the catch block to add it.
       _ = try retrieve()

      let updates = [
        String(kSecAttrGeneric): archived
      ]

      status = SecItemUpdate(query as CFDictionary, updates as CFDictionary)
    } catch KeychainError.notFound {
      query[kSecAttrGeneric as String] = archived
      status = SecItemAdd(query as CFDictionary, nil)
    }

    guard status == noErr else {
      throw KeychainError.secCallFailed(status)
    }
  }

  private func keychainQuery() -> [String: AnyObject] {
    var query: [String: AnyObject] = [:]
    query[kSecClass as String] = kSecClassGenericPassword
    query[kSecAttrService as String] = service as AnyObject
    query[kSecAttrAccount as String] = account as AnyObject

    return query
  }
}


struct UserDataKeychain: Keychain {
  // Make sure the account name doesn't match the bundle identifier!
  var account = "Glow.app.ai"
  var service = "userIdentifier"

  typealias DataType = UserData
}
