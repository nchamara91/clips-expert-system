;;; =====================================================
;;; Fan Troubleshooting Expert System
;;; =====================================================
;;; This expert system helps diagnose and troubleshoot
;;; common problems with electric fans.
;;; =====================================================

;;; =====================================================
;;; TEMPLATES FOR KNOWLEDGE REPRESENTATION
;;; =====================================================

(deftemplate fan-problem
   (slot type (type SYMBOL))
   (slot severity (type SYMBOL) (allowed-values minor moderate severe))
   (slot description (type STRING)))

(deftemplate symptom
   (slot name (type SYMBOL))
   (slot present (type SYMBOL) (allowed-values yes no unknown))
   (slot description (type STRING)))

(deftemplate solution
   (slot for-problem (type SYMBOL))
   (slot action (type STRING))
   (slot difficulty (type SYMBOL) (allowed-values easy medium hard))
   (slot cost (type SYMBOL) (allowed-values low medium high)))

(deftemplate diagnosis
   (slot problem (type SYMBOL))
   (slot confidence (type SYMBOL) (allowed-values low medium high))
   (slot recommendation (type STRING)))

;;; =====================================================
;;; INITIAL FACTS ABOUT FAN PROBLEMS
;;; =====================================================

(deffacts fan-problems
   (fan-problem (type fan-not-working) (severity severe) 
                (description "Fan does not turn on or operate"))
   (fan-problem (type fan-slow) (severity moderate) 
                (description "Fan runs but at reduced speed"))
   (fan-problem (type fan-noisy) (severity minor) 
                (description "Fan makes unusual noises while running"))
   (fan-problem (type fan-wobbling) (severity moderate) 
                (description "Fan wobbles or shakes during operation"))
   (fan-problem (type fan-overheating) (severity severe) 
                (description "Fan motor gets very hot during operation")))

;;; Initial symptoms to check
(deffacts initial-symptoms
   (symptom (name outlet-works) (present unknown) 
            (description "Power outlet works with other devices"))
   (symptom (name power-light-on) (present unknown) 
            (description "Power indicator light is on"))
   (symptom (name cord-damaged) (present unknown) 
            (description "Power cord shows visible damage"))
   (symptom (name makes-sound) (present unknown) 
            (description "Fan makes any sound when switched on"))
   (symptom (name blades-move) (present unknown) 
            (description "Fan blades move at all"))
   (symptom (name moves-slowly) (present unknown) 
            (description "Fan blades move but very slowly"))
   (symptom (name makes-noise) (present unknown) 
            (description "Fan makes grinding, clicking, or unusual noises"))
   (symptom (name wobbles) (present unknown) 
            (description "Fan wobbles or shakes during operation"))
   (symptom (name overheats) (present unknown) 
            (description "Fan motor gets hot during operation")))

;;; Solutions for fan problems
(deffacts problem-solutions
   (solution (for-problem fan-not-working)
             (action "Check power cord and outlet connections")
             (difficulty easy) (cost low))
   (solution (for-problem fan-not-working)
             (action "Replace blown fuse or reset circuit breaker")
             (difficulty medium) (cost low))
   (solution (for-problem fan-not-working)
             (action "Replace faulty motor")
             (difficulty hard) (cost high))
   
   (solution (for-problem fan-slow)
             (action "Clean fan blades and motor housing")
             (difficulty easy) (cost low))
   (solution (for-problem fan-slow)
             (action "Lubricate motor bearings")
             (difficulty medium) (cost low))
   (solution (for-problem fan-slow)
             (action "Replace worn motor capacitor")
             (difficulty medium) (cost medium))
   
   (solution (for-problem fan-noisy)
             (action "Tighten loose screws and bolts")
             (difficulty easy) (cost low))
   (solution (for-problem fan-noisy)
             (action "Replace worn bearings")
             (difficulty hard) (cost medium))
   
   (solution (for-problem fan-wobbling)
             (action "Balance fan blades")
             (difficulty medium) (cost low))
   (solution (for-problem fan-wobbling)
             (action "Tighten mounting hardware")
             (difficulty easy) (cost low))
   
   (solution (for-problem fan-overheating)
             (action "Clean dust from motor vents")
             (difficulty easy) (cost low))
   (solution (for-problem fan-overheating)
             (action "Replace overloaded motor")
             (difficulty hard) (cost high)))

;;; =====================================================
;;; DIAGNOSTIC RULES
;;; =====================================================

;;; Start the troubleshooting process
(defrule start-diagnosis
   (not (diagnosis-started))
   =>
   (assert (diagnosis-started))
   (printout t "=== Fan Troubleshooting Expert System ===" crlf)
   (printout t "I will help you diagnose your fan problem." crlf)
   (printout t "Please answer the following questions with 'yes' or 'no'." crlf crlf))

;;; Ask about power outlet
(defrule ask-outlet-works
   (diagnosis-started)
   ?s <- (symptom (name outlet-works) (present unknown))
   =>
   (printout t "Does the power outlet work with other devices? (yes/no): ")
   (bind ?answer (read))
   (modify ?s (present ?answer)))

;;; Ask about power indicator light
(defrule ask-power-light
   (symptom (name outlet-works) (present yes))
   ?s <- (symptom (name power-light-on) (present unknown))
   =>
   (printout t "Is the fan's power indicator light on? (yes/no): ")
   (bind ?answer (read))
   (modify ?s (present ?answer)))

;;; Ask about fan making sound
(defrule ask-makes-sound
   (symptom (name power-light-on) (present yes))
   ?s <- (symptom (name makes-sound) (present unknown))
   =>
   (printout t "Does the fan make any sound when switched on? (yes/no): ")
   (bind ?answer (read))
   (modify ?s (present ?answer)))

;;; Ask about blade movement
(defrule ask-blades-move
   (symptom (name makes-sound) (present yes))
   ?s <- (symptom (name blades-move) (present unknown))
   =>
   (printout t "Do the fan blades move at all? (yes/no): ")
   (bind ?answer (read))
   (modify ?s (present ?answer)))

;;; Ask about slow movement
(defrule ask-moves-slowly
   (symptom (name blades-move) (present yes))
   ?s <- (symptom (name moves-slowly) (present unknown))
   =>
   (printout t "Do the fan blades move very slowly? (yes/no): ")
   (bind ?answer (read))
   (modify ?s (present ?answer)))

;;; Ask about unusual noises
(defrule ask-makes-noise
   (symptom (name makes-sound) (present yes))
   ?s <- (symptom (name makes-noise) (present unknown))
   =>
   (printout t "Does the fan make grinding, clicking, or unusual noises? (yes/no): ")
   (bind ?answer (read))
   (modify ?s (present ?answer)))

;;; Ask about wobbling
(defrule ask-wobbles
   (symptom (name blades-move) (present yes))
   ?s <- (symptom (name wobbles) (present unknown))
   =>
   (printout t "Does the fan wobble or shake during operation? (yes/no): ")
   (bind ?answer (read))
   (modify ?s (present ?answer)))

;;; Ask about overheating
(defrule ask-overheats
   (symptom (name makes-sound) (present yes))
   ?s <- (symptom (name overheats) (present unknown))
   =>
   (printout t "Does the fan motor get very hot during operation? (yes/no): ")
   (bind ?answer (read))
   (modify ?s (present ?answer)))

;;; =====================================================
;;; DIAGNOSIS RULES
;;; =====================================================

;;; Diagnose: Fan not working - no power
(defrule diagnose-no-power
   (symptom (name outlet-works) (present no))
   =>
   (assert (diagnosis (problem fan-not-working) (confidence high)
                     (recommendation "Check electrical power supply")))
   (printout t crlf "DIAGNOSIS: Fan not working - Power supply problem" crlf)
   (printout t "Confidence: High" crlf)
   (printout t "Recommendation: Check electrical power supply" crlf))

;;; Diagnose: Fan not working - motor problem
(defrule diagnose-motor-problem
   (symptom (name outlet-works) (present yes))
   (symptom (name power-light-on) (present no))
   =>
   (assert (diagnosis (problem fan-not-working) (confidence high)
                     (recommendation "Motor or wiring problem")))
   (printout t crlf "DIAGNOSIS: Fan not working - Motor or wiring problem" crlf)
   (printout t "Confidence: High" crlf)
   (printout t "Recommendation: Check motor and internal wiring" crlf))

;;; Diagnose: Fan not starting
(defrule diagnose-not-starting
   (symptom (name power-light-on) (present yes))
   (symptom (name makes-sound) (present no))
   =>
   (assert (diagnosis (problem fan-not-working) (confidence high)
                     (recommendation "Motor seized or capacitor failed")))
   (printout t crlf "DIAGNOSIS: Fan not starting" crlf)
   (printout t "Confidence: High" crlf)
   (printout t "Recommendation: Motor seized or capacitor failed" crlf))

;;; Diagnose: Fan running slowly
(defrule diagnose-slow-fan
   (symptom (name blades-move) (present yes))
   (symptom (name moves-slowly) (present yes))
   =>
   (assert (diagnosis (problem fan-slow) (confidence high)
                     (recommendation "Clean or lubricate motor")))
   (printout t crlf "DIAGNOSIS: Fan running slowly" crlf)
   (printout t "Confidence: High" crlf)
   (printout t "Recommendation: Clean or lubricate motor" crlf))

;;; Diagnose: Noisy fan
(defrule diagnose-noisy-fan
   (symptom (name makes-noise) (present yes))
   =>
   (assert (diagnosis (problem fan-noisy) (confidence high)
                     (recommendation "Tighten parts or replace bearings")))
   (printout t crlf "DIAGNOSIS: Noisy fan operation" crlf)
   (printout t "Confidence: High" crlf)
   (printout t "Recommendation: Tighten parts or replace bearings" crlf))

;;; Diagnose: Wobbling fan
(defrule diagnose-wobbling-fan
   (symptom (name wobbles) (present yes))
   =>
   (assert (diagnosis (problem fan-wobbling) (confidence high)
                     (recommendation "Balance blades or tighten mounting")))
   (printout t crlf "DIAGNOSIS: Fan wobbling" crlf)
   (printout t "Confidence: High" crlf)
   (printout t "Recommendation: Balance blades or tighten mounting" crlf))

;;; Diagnose: Overheating fan
(defrule diagnose-overheating-fan
   (symptom (name overheats) (present yes))
   =>
   (assert (diagnosis (problem fan-overheating) (confidence high)
                     (recommendation "Clean vents or check motor load")))
   (printout t crlf "DIAGNOSIS: Fan overheating" crlf)
   (printout t "Confidence: High" crlf)
   (printout t "Recommendation: Clean vents or check motor load" crlf))

;;; Provide solutions based on diagnosis
(defrule provide-solutions
   (diagnosis (problem ?prob))
   (solution (for-problem ?prob) (action ?action) (difficulty ?diff) (cost ?cost))
   =>
   (printout t "SOLUTION: " ?action crlf)
   (printout t "Difficulty: " ?diff crlf)
   (printout t "Cost: " ?cost crlf crlf))

;;; End diagnosis
(defrule end-diagnosis
   (diagnosis (problem ?prob))
   =>
   (printout t "=== End of Diagnosis ===" crlf)
   (printout t "If the problem persists, consult a professional technician." crlf))