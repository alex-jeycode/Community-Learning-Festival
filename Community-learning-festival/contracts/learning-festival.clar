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

;; Update workshop title
;;#[allow(unchecked_data)]
(define-public (update-workshop-title (workshop-id uint) (new-title (string-ascii 100)))
    (let
        (
            (workshop (unwrap! (map-get? workshops { workshop-id: workshop-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender (get organizer workshop)) err-owner-only)
        (map-set workshops
            { workshop-id: workshop-id }
            (merge workshop { title: new-title })
        )
        (ok true)
    )
)

;; Update workshop category
;;#[allow(unchecked_data)]
(define-public (update-workshop-category (workshop-id uint) (new-category (string-ascii 30)))
    (let
        (
            (workshop (unwrap! (map-get? workshops { workshop-id: workshop-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender (get organizer workshop)) err-owner-only)
        (map-set workshops
            { workshop-id: workshop-id }
            (merge workshop { category: new-category })
        )
        (ok true)
    )
)

;; Update workshop capacity
;;#[allow(unchecked_data)]
(define-public (update-workshop-capacity (workshop-id uint) (new-capacity uint))
    (let
        (
            (workshop (unwrap! (map-get? workshops { workshop-id: workshop-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender (get organizer workshop)) err-owner-only)
        (asserts! (>= new-capacity (get registered workshop)) (err u105))
        (map-set workshops
            { workshop-id: workshop-id }
            (merge workshop { capacity: new-capacity })
        )
        (ok true)
    )
)

;; Cancel registration
;;#[allow(unchecked_data)]
(define-public (cancel-registration (workshop-id uint))
    (let
        (
            (workshop (unwrap! (map-get? workshops { workshop-id: workshop-id }) err-not-found))
            (registration (unwrap! (map-get? participant-registrations { participant: tx-sender, workshop-id: workshop-id }) err-not-found))
        )
        (map-delete participant-registrations { participant: tx-sender, workshop-id: workshop-id })
        (map-set workshops
            { workshop-id: workshop-id }
            (merge workshop { registered: (- (get registered workshop) u1) })
        )
        (ok true)
    )
)

;; Add feedback score
(define-map workshop-feedback
    { workshop-id: uint, participant: principal }
    { score: uint, comment: (string-ascii 200) }
)

;; Submit workshop feedback
;;#[allow(unchecked_data)]
(define-public (submit-feedback (workshop-id uint) (score uint) (comment (string-ascii 200)))
    (let
        (
            (registration (unwrap! (map-get? participant-registrations { participant: tx-sender, workshop-id: workshop-id }) err-not-found))
        )
        (asserts! (get attended registration) (err u106))
        (asserts! (<= score u5) (err u107))
        (map-set workshop-feedback
            { workshop-id: workshop-id, participant: tx-sender }
            { score: score, comment: comment }
        )
        (ok true)
    )
)

;; Get feedback
(define-read-only (get-feedback (workshop-id uint) (participant principal))
    (map-get? workshop-feedback { workshop-id: workshop-id, participant: participant })
)

;; Workshop tags map
(define-map workshop-tags
    { workshop-id: uint }
    { tag1: (string-ascii 20), tag2: (string-ascii 20), tag3: (string-ascii 20) }
)

;; Add tags to workshop
;;#[allow(unchecked_data)]
(define-public (add-workshop-tags (workshop-id uint) (tag1 (string-ascii 20)) (tag2 (string-ascii 20)) (tag3 (string-ascii 20)))
    (let
        (
            (workshop (unwrap! (map-get? workshops { workshop-id: workshop-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender (get organizer workshop)) err-owner-only)
        (map-set workshop-tags
            { workshop-id: workshop-id }
            { tag1: tag1, tag2: tag2, tag3: tag3 }
        )
        (ok true)
    )
)

;; Get workshop tags
(define-read-only (get-workshop-tags (workshop-id uint))
    (map-get? workshop-tags { workshop-id: workshop-id })
)

;; Workshop ratings aggregation
(define-map workshop-ratings
    { workshop-id: uint }
    { total-score: uint, rating-count: uint }
)

;; Update workshop rating
;;#[allow(unchecked_data)]
(define-public (update-workshop-rating (workshop-id uint) (score uint))
    (let
        (
            (current-rating (default-to { total-score: u0, rating-count: u0 } (map-get? workshop-ratings { workshop-id: workshop-id })))
        )
        (asserts! (<= score u5) (err u107))
        (map-set workshop-ratings
            { workshop-id: workshop-id }
            {
                total-score: (+ (get total-score current-rating) score),
                rating-count: (+ (get rating-count current-rating) u1)
            }
        )
        (ok true)
    )
)

;; Get workshop rating
(define-read-only (get-workshop-rating (workshop-id uint))
    (map-get? workshop-ratings { workshop-id: workshop-id })
)

;; Calculate average rating
(define-read-only (get-average-rating (workshop-id uint))
    (let
        (
            (rating (unwrap! (map-get? workshop-ratings { workshop-id: workshop-id }) err-not-found))
        )
        (ok (/ (get total-score rating) (get rating-count rating)))
    )
)

;; Participant statistics
(define-map participant-stats
    { participant: principal }
    { workshops-attended: uint, workshops-registered: uint, total-feedback: uint }
)

;; Update participant stats
;;#[allow(unchecked_data)]
(define-public (update-participant-stats (participant principal) (attended uint) (registered uint))
    (let
        (
            (current-stats (default-to { workshops-attended: u0, workshops-registered: u0, total-feedback: u0 } (map-get? participant-stats { participant: participant })))
        )
        (map-set participant-stats
            { participant: participant }
            {
                workshops-attended: (+ (get workshops-attended current-stats) attended),
                workshops-registered: (+ (get workshops-registered current-stats) registered),
                total-feedback: (get total-feedback current-stats)
            }
        )
        (ok true)
    )
)

;; Get participant stats
(define-read-only (get-participant-stats (participant principal))
    (map-get? participant-stats { participant: participant })
)

;; Workshop certificates
(define-map certificates
    { workshop-id: uint, participant: principal }
    { issued: bool, issue-date: uint }
)

;; Issue certificate
;;#[allow(unchecked_data)]
(define-public (issue-certificate (workshop-id uint) (participant principal))
    (let
        (
            (workshop (unwrap! (map-get? workshops { workshop-id: workshop-id }) err-not-found))
            (registration (unwrap! (map-get? participant-registrations { participant: participant, workshop-id: workshop-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender (get organizer workshop)) err-owner-only)
        (asserts! (get attended registration) (err u106))
        (map-set certificates
            { workshop-id: workshop-id, participant: participant }
            { issued: true, issue-date: stacks-block-height }
        )
        (ok true)
    )
)

;; Get certificate
(define-read-only (get-certificate (workshop-id uint) (participant principal))
    (map-get? certificates { workshop-id: workshop-id, participant: participant })
)

;; Verify certificate
(define-read-only (verify-certificate (workshop-id uint) (participant principal))
    (let
        (
            (cert (map-get? certificates { workshop-id: workshop-id, participant: participant }))
        )
        (ok (is-some cert))
    )
)

;; Workshop prerequisites
(define-map workshop-prerequisites
    { workshop-id: uint }
    { required-workshop: uint, min-experience: uint }
)

;; Set workshop prerequisites
;;#[allow(unchecked_data)]
(define-public (set-prerequisites (workshop-id uint) (required-workshop uint) (min-experience uint))
    (let
        (
            (workshop (unwrap! (map-get? workshops { workshop-id: workshop-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender (get organizer workshop)) err-owner-only)
        (map-set workshop-prerequisites
            { workshop-id: workshop-id }
            { required-workshop: required-workshop, min-experience: min-experience }
        )
        (ok true)
    )
)

;; Get prerequisites
(define-read-only (get-prerequisites (workshop-id uint))
    (map-get? workshop-prerequisites { workshop-id: workshop-id })
)

;; Check if participant meets prerequisites
(define-read-only (meets-prerequisites (workshop-id uint) (participant principal))
    (let
        (
            (prereqs (unwrap! (map-get? workshop-prerequisites { workshop-id: workshop-id }) err-not-found))
            (stats (default-to { workshops-attended: u0, workshops-registered: u0, total-feedback: u0 } (map-get? participant-stats { participant: participant })))
        )
        (ok (>= (get workshops-attended stats) (get min-experience prereqs)))
    )
)