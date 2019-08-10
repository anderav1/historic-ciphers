// Lexi Anderson
// CS 4732
// Project 1
// using Swift language

import Foundation

// Task 1 -- Vigenere cipher

// allow use of String subscript accessor
extension StringProtocol {        
    subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }
}

// helper function
func modulo(_ dividend: Int, _ divisor: Int) -> Int {
	let remainder = dividend % divisor
	if remainder < 0 { return remainder + divisor } else { return remainder }
}

class VigenereCipher {
	private func caesarEncipher(letter: Character, cipher: Character) -> Character {
		let shift = modulo(Int(letter.asciiValue! - 97) + Int(cipher.asciiValue! - 97), 26) + 97
		let encipheredLetterValue = UnicodeScalar(shift)
		return Character(encipheredLetterValue!)
	}
	
	private func caesarDecipher(letter: Character, cipher: Character) -> Character {
		let shift = modulo(Int(letter.asciiValue!) - Int(cipher.asciiValue!), 26) + 97
		let decipheredLetterValue = UnicodeScalar(shift)
		return Character(decipheredLetterValue!)
	}

	func encryption(plaintext: String, key: String) -> String? {
		let cleanKey = key.filter { $0.isLetter }
		guard cleanKey.count >= 1 else { print("Key cannot be empty"); return nil }
		let lowercasePlaintextLetters = plaintext.filter { $0.isLetter }.lowercased()
		var encryptedMessage: String = ""
		var currentCipherIndex = 0
	
		for letter in lowercasePlaintextLetters {
			if currentCipherIndex >= cleanKey.count {
				currentCipherIndex = 0
			}
			encryptedMessage.append(caesarEncipher(letter: letter, cipher: cleanKey[currentCipherIndex]))
			currentCipherIndex += 1
		}
	
		return encryptedMessage
	}
	
	func decryption(ciphertext: String, key: String) -> String? {
		let cleanKey = key.filter { $0.isLetter }
		guard cleanKey.count >= 1 else { print("Key cannot be empty"); return nil }
		let lowercaseCiphertextLetters = ciphertext.filter { $0.isLetter }.lowercased()
		var decryptedMessage: String = ""
		var currentCipherIndex = 0
		
		for letter in lowercaseCiphertextLetters {
			if currentCipherIndex >= cleanKey.count {
				currentCipherIndex = 0
			}
			decryptedMessage.append(caesarDecipher(letter: letter, cipher: cleanKey[currentCipherIndex]))
			currentCipherIndex += 1
		}
		
		return decryptedMessage
	}
}


// Task 2 -- Brute force decryption of Vigenere cipher

func bruteForce(ciphertext: String, plaintextSubstring: String, maxKeySize: Int) {
	let encryptedText = ciphertext.lowercased().filter { $0.isLetter }
	let plaintextFragment = plaintextSubstring.lowercased().filter { $0.isLetter }

	for currentKeySize in 1...maxKeySize {
		testKeysOfSize(ciphertext: encryptedText, plaintextSubstring: plaintextFragment, keySize: currentKeySize)
		print("\nFinished testing keys of size \(currentKeySize).")
		if currentKeySize != maxKeySize {
			print("Would you like to continue testing longer keys? (y/n) ")
			let willContinue = readLine() ?? ""
			if willContinue.lowercased() != "y" { break }
		}

	}
	print("Brute force analysis complete.")
}

func testKeysOfSize(ciphertext: String, plaintextSubstring: String, keySize: Int) {
	let cipher = VigenereCipher()
	var possibleKey: String? = String(repeating: "a", count: keySize)
	let indexOfLetterToChange = possibleKey!.count - 1
	var willContinue = "y"
	
	repeat {
		//repeat {
			
		//} while possibleKey != nil
		let possibleDecryption = cipher.decryption(ciphertext: ciphertext, key: possibleKey!)!
		if possibleDecryption.contains(plaintextSubstring) {
			print("Message: \(possibleDecryption)\tKey: \(possibleKey!)")
			print("Possible decryption found. Would you like to continue? (y/n) ")
			willContinue = readLine() ?? ""
			if willContinue.lowercased() == "n" { return () }
		}
		
		possibleKey = generateNextKey(after: possibleKey!, changeIndex: indexOfLetterToChange)
	} while willContinue.lowercased() == "y" && possibleKey != nil
}

func generateNextKey(after currentKey: String, changeIndex: Int) -> String? {
	let lastKey = String(repeating: "z", count: currentKey.count)
	if currentKey == lastKey { return nil }
	
	var keyLetters = Array(currentKey)
	keyLetters[changeIndex] = incrementLetter(letter: currentKey[changeIndex])
	var offset = 0
	while keyLetters[changeIndex - offset] == "a" {
		offset += 1
		keyLetters[changeIndex - offset] = incrementLetter(letter: currentKey[changeIndex - offset])
	}
	return String(keyLetters)
}

func incrementLetter(letter: Character) -> Character {
	let newLetterValue = UnicodeScalar(modulo((Int(letter.asciiValue!) - 97 + 1), 26) + 97)
	return Character(newLetterValue!)
}


// Main execution code

var task: Int
var lastCiphertext = "lastciphertextgenerated"

repeat {
	print("\nEnter the number of the task you wish to execute.")
	print("1. Vigenere cipher encryption/decryption")
	print("2. Brute-force attack on the Vigenere cipher")
	print("3. Quit\n")
	let userInput = readLine() ?? ""
	task = Int(userInput) ?? 0
	
	switch task {
	case 1:
		let vigenereCipher = VigenereCipher()

		print("Enter a plaintext to encrypt: ")
		let plaintext = readLine() ?? ""
		print("Enter the secret key: ")
		let key = readLine() ?? ""

		let encryptedText = vigenereCipher.encryption(plaintext: plaintext, key: key) ?? ""
		print("Encrypted text: \(encryptedText)")
		lastCiphertext = encryptedText
		let decryptedText = vigenereCipher.decryption(ciphertext: encryptedText, key: key) ?? ""
		print("Decrypted text: \(decryptedText)")
	case 2:
		print("Enter the ciphertext encoded with the Vigenere cipher, or press enter to use the most recent ciphertext generated: ")
		var ciphertext: String
		if let input = readLine() {
			let validKeyCharacters = input.filter { $0.isLetter }
			if validKeyCharacters.isEmpty {
				print("Using previously generated ciphertext \"\(lastCiphertext)\"")
				ciphertext = lastCiphertext
			} else {
				ciphertext = validKeyCharacters
			}
		} else {
			ciphertext = lastCiphertext
			print(lastCiphertext)
		}
		print("Enter a substring from the plaintext: ")
		let plaintextSubstring = readLine() ?? ""
		print("What is the maximum size of the key? (1-10): ")
		let maxKeySizeString = readLine() ?? ""
		let maxKeySize = Int(maxKeySizeString) ?? 10
		
		bruteForce(ciphertext: ciphertext, plaintextSubstring: plaintextSubstring, maxKeySize: maxKeySize)
	case 3: break
	default: continue
	}
} while task != 3


