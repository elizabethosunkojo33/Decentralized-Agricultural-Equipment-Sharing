;; Equipment Registration Contract
;; Records details of farm machinery

(define-data-var last-equipment-id uint u0)

(define-map equipments
  { equipment-id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    owner: principal,
    daily-rate: uint,
    available: bool,
    condition: (string-ascii 50)
  }
)

(define-public (register-equipment
    (name (string-ascii 100))
    (description (string-ascii 500))
    (daily-rate uint)
    (condition (string-ascii 50)))
  (let ((new-id (+ (var-get last-equipment-id) u1)))
    (begin
      (var-set last-equipment-id new-id)
      (map-set equipments
        { equipment-id: new-id }
        {
          name: name,
          description: description,
          owner: tx-sender,
          daily-rate: daily-rate,
          available: true,
          condition: condition
        }
      )
      (ok new-id)
    )
  )
)

(define-public (update-equipment-availability
    (equipment-id uint)
    (available bool))
  (let ((equipment (unwrap! (map-get? equipments { equipment-id: equipment-id }) (err u1))))
    (if (is-eq tx-sender (get owner equipment))
      (begin
        (map-set equipments
          { equipment-id: equipment-id }
          (merge equipment { available: available })
        )
        (ok true)
      )
      (err u2) ;; Not the owner
    )
  )
)

(define-public (update-equipment-condition
    (equipment-id uint)
    (condition (string-ascii 50)))
  (let ((equipment (unwrap! (map-get? equipments { equipment-id: equipment-id }) (err u1))))
    (if (is-eq tx-sender (get owner equipment))
      (begin
        (map-set equipments
          { equipment-id: equipment-id }
          (merge equipment { condition: condition })
        )
        (ok true)
      )
      (err u2) ;; Not the owner
    )
  )
)

(define-read-only (get-equipment (equipment-id uint))
  (map-get? equipments { equipment-id: equipment-id })
)

(define-read-only (get-equipment-count)
  (var-get last-equipment-id)
)
