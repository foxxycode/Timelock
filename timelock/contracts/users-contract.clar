;; Time-locked Wallet Contract
;; Allows funds to be locked until a specific block height

;; Error codes
(define-constant err-not-authorized (err u100))
(define-constant err-funds-locked (err u101))
(define-constant err-no-funds (err u102))
(define-constant err-invalid-unlock-height (err u103))

;; Contract variables
(define-data-var contract-owner principal tx-sender)

;; Map to store time-locked wallets
;; Key: wallet-id, Value: {owner, unlock-height, amount}
(define-map time-locked-wallets 
  { wallet-id: uint }
  {
    owner: principal,
    unlock-height: uint,
    amount: uint
  }
)

;; Global wallet counter
(define-data-var next-wallet-id uint u1)

;; Get next available wallet ID
(define-private (get-next-wallet-id)
  (let ((current-id (var-get next-wallet-id)))
    (var-set next-wallet-id (+ current-id u1))
    current-id
  )
)

;; Create a time-locked wallet
(define-public (create-timelock (unlock-height uint) (amount uint))
  (let (
    (wallet-id (get-next-wallet-id))
    (current-height block-height)
  )
    (asserts! (> unlock-height current-height) err-invalid-unlock-height)
    (asserts! (> amount u0) err-no-funds)
    
    ;; Transfer STX to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Store wallet info
    (map-set time-locked-wallets 
      { wallet-id: wallet-id }
      {
        owner: tx-sender,
        unlock-height: unlock-height,
        amount: amount
      }
    )
    (ok wallet-id)
  )
)

;; Withdraw funds from time-locked wallet
(define-public (withdraw (wallet-id uint))
  (let (
    (wallet-data (unwrap! (map-get? time-locked-wallets { wallet-id: wallet-id }) err-no-funds))
    (owner (get owner wallet-data))
    (unlock-height (get unlock-height wallet-data))
    (amount (get amount wallet-data))
  )
    ;; Check authorization
    (asserts! (is-eq tx-sender owner) err-not-authorized)
    
    ;; Check if funds are unlocked
    (asserts! (>= block-height unlock-height) err-funds-locked)
    
    ;; Transfer funds back to owner
    (try! (as-contract (stx-transfer? amount tx-sender owner)))
    
    ;; Remove wallet from map
    (map-delete time-locked-wallets { wallet-id: wallet-id })
    
    (ok amount)
  )
)

;; Get wallet info
(define-read-only (get-wallet-info (wallet-id uint))
  (map-get? time-locked-wallets { wallet-id: wallet-id })
)

;; Check if wallet is unlocked
(define-read-only (is-wallet-unlocked (wallet-id uint))
  (match (map-get? time-locked-wallets { wallet-id: wallet-id })
    wallet-data (>= block-height (get unlock-height wallet-data))
    false
  )
)

;; Get current block height (helper function)
(define-read-only (get-current-block-height)
  block-height
)

;; Emergency function for contract owner (optional safety feature)
(define-public (emergency-withdraw (wallet-id uint))
  (let (
    (wallet-data (unwrap! (map-get? time-locked-wallets { wallet-id: wallet-id }) err-no-funds))
    (amount (get amount wallet-data))
  )
    ;; Only contract owner can use this
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorized)
    
    ;; Transfer funds to contract owner
    (try! (as-contract (stx-transfer? amount tx-sender (var-get contract-owner))))
    
    ;; Remove wallet from map
    (map-delete time-locked-wallets { wallet-id: wallet-id })
    
    (ok amount)
  )
)