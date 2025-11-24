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