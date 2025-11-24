;; learning-festival.clar
;; Community Learning Festival workshop and participant management

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-workshop-full (err u103))

;; Data variables
(define-data-var workshop-counter uint u0)
(define-data-var festival-active bool false)

;; Data maps
(define-map workshops
    { workshop-id: uint }
    {
        organizer: principal,
        title: (string-ascii 100),
        category: (string-ascii 30),
        capacity: uint,
        registered: uint,
        timestamp: uint
    }
)

(define-map participant-registrations
    { participant: principal, workshop-id: uint }
    { registered: bool, attended: bool }
)

(define-map organizer-profiles
    { organizer: principal }
    { workshops-created: uint, total-participants: uint }
)

;; Toggle festival status
(define-public (set-festival-status (active bool))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set festival-active active)
        (ok true)
    )
)

;; Create workshop
;;#[allow(unchecked_data)]
(define-public (create-workshop (title (string-ascii 100)) (category (string-ascii 30)) (capacity uint))
    (let
        (
            (new-id (+ (var-get workshop-counter) u1))
        )
        (asserts! (var-get festival-active) (err u104))
        (map-set workshops
            { workshop-id: new-id }
            {
                organizer: tx-sender,
                title: title,
                category: category,
                capacity: capacity,
                registered: u0,
                timestamp: stacks-block-height
            }
        )
        (var-set workshop-counter new-id)
        (ok new-id)
    )
)

;; Register for workshop
;;#[allow(unchecked_data)]
(define-public (register-for-workshop (workshop-id uint))
    (let
        (
            (workshop (unwrap! (map-get? workshops { workshop-id: workshop-id }) err-not-found))
        )
        (asserts! (< (get registered workshop) (get capacity workshop)) err-workshop-full)
        (asserts! (is-none (map-get? participant-registrations { participant: tx-sender, workshop-id: workshop-id })) err-already-exists)
        (map-set participant-registrations
            { participant: tx-sender, workshop-id: workshop-id }
            { registered: true, attended: false }
        )
        (map-set workshops
            { workshop-id: workshop-id }
            (merge workshop { registered: (+ (get registered workshop) u1) })
        )
        (ok true)
    )
)

;; Mark attendance
;;#[allow(unchecked_data)]
(define-public (mark-attendance (workshop-id uint))
    (let
        (
            (registration (unwrap! (map-get? participant-registrations { participant: tx-sender, workshop-id: workshop-id }) err-not-found))
        )
        (map-set participant-registrations
            { participant: tx-sender, workshop-id: workshop-id }
            (merge registration { attended: true })
        )
        (ok true)
    )
)

;; Read-only functions
(define-read-only (get-workshop (workshop-id uint))
    (map-get? workshops { workshop-id: workshop-id })
)

(define-read-only (get-registration (participant principal) (workshop-id uint))
    (map-get? participant-registrations { participant: participant, workshop-id: workshop-id })
)

(define-read-only (is-festival-active)
    (ok (var-get festival-active))
)

(define-read-only (get-workshop-count)
    (ok (var-get workshop-counter))
)

;; Toggle festival status
(define-public (set-festival-status (active bool))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set festival-active active)
        (ok true)
    )
)

;; Create workshop
;;#[allow(unchecked_data)]
(define-public (create-workshop (title (string-ascii 100)) (category (string-ascii 30)) (capacity uint))
    (let
        (
            (new-id (+ (var-get workshop-counter) u1))
        )
        (asserts! (var-get festival-active) (err u104))
        (map-set workshops
            { workshop-id: new-id }
            {
                organizer: tx-sender,
                title: title,
                category: category,
                capacity: capacity,
                registered: u0,
                timestamp: stacks-block-height
            }
        )
        (var-set workshop-counter new-id)
        (ok new-id)
    )
)

;; Register for workshop
;;#[allow(unchecked_data)]
(define-public (register-for-workshop (workshop-id uint))
    (let
        (
            (workshop (unwrap! (map-get? workshops { workshop-id: workshop-id }) err-not-found))
        )
        (asserts! (< (get registered workshop) (get capacity workshop)) err-workshop-full)
        (asserts! (is-none (map-get? participant-registrations { participant: tx-sender, workshop-id: workshop-id })) err-already-exists)
        (map-set participant-registrations
            { participant: tx-sender, workshop-id: workshop-id }
            { registered: true, attended: false }
        )
        (map-set workshops
            { workshop-id: workshop-id }
            (merge workshop { registered: (+ (get registered workshop) u1) })
        )
        (ok true)
    )
)

;; Mark attendance
;;#[allow(unchecked_data)]
(define-public (mark-attendance (workshop-id uint))
    (let
        (
            (registration (unwrap! (map-get? participant-registrations { participant: tx-sender, workshop-id: workshop-id }) err-not-found))
        )
        (map-set participant-registrations
            { participant: tx-sender, workshop-id: workshop-id }
            (merge registration { attended: true })
        )
        (ok true)
    )
)

;; Read-only functions
(define-read-only (get-workshop (workshop-id uint))
    (map-get? workshops { workshop-id: workshop-id })
)

(define-read-only (get-registration (participant principal) (workshop-id uint))
    (map-get? participant-registrations { participant: participant, workshop-id: workshop-id })
)

(define-read-only (is-festival-active)
    (ok (var-get festival-active))
)

(define-read-only (get-workshop-count)
    (ok (var-get workshop-counter))
)