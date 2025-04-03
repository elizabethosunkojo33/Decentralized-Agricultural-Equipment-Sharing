;; Farmer Verification Contract
;; Validates legitimate agricultural operators

(define-map verified-farmers
  { farmer: principal }
  {
    is-verified: bool,
    verification-date: uint,
    farm-name: (string-ascii 100),
    farm-location: (string-ascii 100)
  }
)

;; Only contract owner can verify farmers
(define-constant contract-owner tx-sender)

(define-public (verify-farmer
    (farmer principal)
    (farm-name (string-ascii 100))
    (farm-location (string-ascii 100)))
  (if (is-eq tx-sender contract-owner)
    (begin
      (map-set verified-farmers
        { farmer: farmer }
        {
          is-verified: true,
          verification-date: block-height,
          farm-name: farm-name,
          farm-location: farm-location
        }
      )
      (ok true)
    )
    (err u1) ;; Not authorized
  )
)

(define-public (revoke-verification (farmer principal))
  (if (is-eq tx-sender contract-owner)
    (let ((farmer-data (unwrap! (map-get? verified-farmers { farmer: farmer }) (err u2))))
      (begin
        (map-set verified-farmers
          { farmer: farmer }
          (merge farmer-data { is-verified: false })
        )
        (ok true)
      )
    )
    (err u1) ;; Not authorized
  )
)

(define-read-only (is-farmer-verified (farmer principal))
  (default-to false (get is-verified (map-get? verified-farmers { farmer: farmer })))
)

(define-read-only (get-farmer-details (farmer principal))
  (map-get? verified-farmers { farmer: farmer })
)
