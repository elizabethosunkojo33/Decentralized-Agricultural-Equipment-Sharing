;; Intellectual Property Contract
;; Manages rights to discoveries and innovations

(define-data-var last-ip-id uint u0)

(define-map intellectual-properties
  { ip-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    creator: principal,
    creation-date: uint,
    contributors: (list 10 principal),
    license-type: (string-ascii 50)
  }
)

(define-map ip-licenses
  { ip-id: uint, licensee: principal }
  {
    granted-by: principal,
    granted-at: uint,
    expiry: uint,
    terms: (string-ascii 500)
  }
)

(define-public (register-intellectual-property
    (title (string-ascii 100))
    (description (string-ascii 500))
    (contributors (list 10 principal))
    (license-type (string-ascii 50)))
  (let ((new-id (+ (var-get last-ip-id) u1)))
    (begin
      (var-set last-ip-id new-id)
      (map-set intellectual-properties
        { ip-id: new-id }
        {
          title: title,
          description: description,
          creator: tx-sender,
          creation-date: block-height,
          contributors: contributors,
          license-type: license-type
        }
      )
      (ok new-id)
    )
  )
)

(define-public (grant-license
    (ip-id uint)
    (licensee principal)
    (expiry uint)
    (terms (string-ascii 500)))
  (let ((ip (unwrap! (map-get? intellectual-properties { ip-id: ip-id }) (err u1))))
    (if (is-eq tx-sender (get creator ip))
      (begin
        (map-set ip-licenses
          { ip-id: ip-id, licensee: licensee }
          {
            granted-by: tx-sender,
            granted-at: block-height,
            expiry: expiry,
            terms: terms
          }
        )
        (ok true)
      )
      (err u2) ;; Not the IP creator
    )
  )
)

(define-read-only (get-intellectual-property (ip-id uint))
  (map-get? intellectual-properties { ip-id: ip-id })
)

(define-read-only (get-license (ip-id uint) (licensee principal))
  (map-get? ip-licenses { ip-id: ip-id, licensee: licensee })
)

(define-read-only (is-license-valid (ip-id uint) (licensee principal))
  (let ((license (map-get? ip-licenses { ip-id: ip-id, licensee: licensee })))
    (if (is-some license)
      (< block-height (get expiry (unwrap! license false)))
      false
    )
  )
)
