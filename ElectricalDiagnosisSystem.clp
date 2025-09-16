;; ================================================================
;; ELECTRICAL APPLIANCE DIAGNOSIS EXPERT SYSTEM
;; Author: Expert System for Electrical Issues
;; Date: September 16, 2025
;; Description: Diagnoses electrical issues in fans, washing machines, and TVs
;; Features: Forward/Backward chaining, Why/How explanations
;; ================================================================

(clear)

;; ================================================================
;; TEMPLATES AND DATA STRUCTURES
;; ================================================================

(deftemplate appliance
    (slot type (allowed-values fan washing-machine tv))
    (slot brand)
    (slot model)
    (slot age (type INTEGER))
    (slot power-rating (type INTEGER)))

(deftemplate symptom
    (slot appliance-type (allowed-values fan washing-machine tv))
    (slot name)
    (slot severity (allowed-values low medium high))
    (slot observed (allowed-values yes no unknown)))

(deftemplate measurement
    (slot appliance-type (allowed-values fan washing-machine tv))
    (slot parameter (allowed-values voltage current resistance power frequency))
    (slot value (type FLOAT))
    (slot unit)
    (slot normal-range))

(deftemplate diagnosis
    (slot appliance-type (allowed-values fan washing-machine tv))
    (slot problem)
    (slot confidence (type FLOAT) (range 0.0 1.0))
    (slot solution)
    (slot cost-estimate (type FLOAT))
    (slot urgency (allowed-values low medium high critical)))

(deftemplate explanation
    (slot rule-name)
    (slot conclusion)
    (slot reasoning)
    (slot evidence (type STRING)))

(deftemplate question
    (slot id (type INTEGER))
    (slot text)
    (slot appliance-type (allowed-values fan washing-machine tv))
    (slot asked (allowed-values yes no))
    (slot answer))

(deftemplate hypothesis
    (slot appliance-type (allowed-values fan washing-machine tv))
    (slot problem)
    (slot status (allowed-values active proven disproven))
    (slot confidence (type FLOAT) (range 0.0 1.0))
    (slot evidence-required))

(defglobal ?*explanation-enabled* = TRUE)
(defglobal ?*current-appliance* = nil)
(defglobal ?*bc-mode* = FALSE)

;; ================================================================
;; UTILITY FUNCTIONS
;; ================================================================

(deffunction ask-user (?question)
    (printout t ?question " (yes/no): ")
    (bind ?answer (read))
    (while (and (neq ?answer yes) (neq ?answer no) (neq ?answer y) (neq ?answer n))
        (printout t "Please answer yes/no (or y/n): ")
        (bind ?answer (read)))
    (if (or (eq ?answer yes) (eq ?answer y))
        then yes
        else no))

(deffunction ask-number (?question ?min ?max)
    (printout t ?question " (" ?min "-" ?max "): ")
    (bind ?answer (read))
    (while (or (not (numberp ?answer)) (< ?answer ?min) (> ?answer ?max))
        (printout t "Please enter a number between " ?min " and " ?max ": ")
        (bind ?answer (read)))
    ?answer)

(deffunction record-explanation (?rule ?conclusion ?reasoning ?evidence)
    (if ?*explanation-enabled*
        then (assert (explanation
                (rule-name ?rule)
                (conclusion ?conclusion)
                (reasoning ?reasoning)
                (evidence ?evidence)))))

(deffunction enable-backward-chaining ()
    (bind ?*bc-mode* TRUE)
    (printout t crlf "=== BACKWARD CHAINING MODE ENABLED ===" crlf)
    (printout t "System will test hypotheses systematically." crlf))

;; ================================================================
;; INITIAL FACTS AND STARTUP
;; ================================================================

(deffacts initial-facts
    (start-diagnosis))

;; ================================================================
;; MAIN CONTROL RULES
;; ================================================================

(defrule start-system
    ?start <- (start-diagnosis)
    =>
    (retract ?start)
    (printout t crlf "=========================================" crlf)
    (printout t "ELECTRICAL APPLIANCE DIAGNOSIS SYSTEM" crlf)
    (printout t "=========================================" crlf)
    (printout t "This system can diagnose electrical issues in:" crlf)
    (printout t "1. Fans" crlf)
    (printout t "2. Washing Machines" crlf)
    (printout t "3. TVs" crlf)
    (printout t crlf)
    (assert (select-appliance)))

(defrule select-appliance-type
    ?select <- (select-appliance)
    =>
    (retract ?select)
    (printout t "Which appliance are you diagnosing?" crlf)
    (printout t "1. Fan" crlf)
    (printout t "2. Washing Machine" crlf)
    (printout t "3. TV" crlf)
    (printout t "Enter choice (1-3): ")
    (bind ?choice (read))
    (switch ?choice
        (case 1 then (assert (appliance (type fan)))
                    (bind ?*current-appliance* fan)
                    (assert (gather-fan-symptoms)))
        (case 2 then (assert (appliance (type washing-machine)))
                    (bind ?*current-appliance* washing-machine)
                    (assert (gather-washing-machine-symptoms)))
        (case 3 then (assert (appliance (type tv)))
                    (bind ?*current-appliance* tv)
                    (assert (gather-tv-symptoms)))
        (default (printout t "Invalid choice. Please restart." crlf))))

;; ================================================================
;; FAN DIAGNOSIS RULES
;; ================================================================

(defrule gather-fan-symptoms
    ?gather <- (gather-fan-symptoms)
    =>
    (retract ?gather)
    (printout t crlf "=== FAN DIAGNOSIS ===" crlf)
    
    (if (eq (ask-user "Does the fan not turn on at all?") yes)
        then (assert (symptom (appliance-type fan) (name no-power) (observed yes))))
    
    (if (eq (ask-user "Does the fan make unusual noises (grinding, squeaking)?") yes)
        then (assert (symptom (appliance-type fan) (name unusual-noise) (observed yes))))
    
    (if (eq (ask-user "Does the fan run very slowly or intermittently?") yes)
        then (assert (symptom (appliance-type fan) (name slow-running) (observed yes))))
    
    (if (eq (ask-user "Does the fan wobble or vibrate excessively?") yes)
        then (assert (symptom (appliance-type fan) (name excessive-vibration) (observed yes))))
    
    (if (eq (ask-user "Does the fan overheat or smell like burning?") yes)
        then (assert (symptom (appliance-type fan) (name overheating) (observed yes))))
    
    (assert (diagnose-fan)))

(defrule fan-no-power-diagnosis
    (appliance (type fan))
    (symptom (appliance-type fan) (name no-power) (observed yes))
    =>
    (bind ?voltage-ok (ask-user "Is there power at the outlet (tested with multimeter)?"))
    (if (eq ?voltage-ok no)
        then (assert (diagnosis 
                (appliance-type fan)
                (problem "Power supply failure")
                (confidence 0.9)
                (solution "Check circuit breaker, replace fuse, or repair outlet wiring")
                (cost-estimate 50.0)
                (urgency medium)))
             (record-explanation "fan-no-power-diagnosis" 
                               "Power supply failure"
                               "No power at outlet indicates electrical supply issue"
                               "Outlet voltage test failed")
        else (if (eq (ask-user "Are the fan wires properly connected?") no)
                then (assert (diagnosis 
                        (appliance-type fan)
                        (problem "Loose wiring connections")
                        (confidence 0.8)
                        (solution "Tighten wire connections and check for corrosion")
                        (cost-estimate 20.0)
                        (urgency medium)))
                     (record-explanation "fan-no-power-diagnosis"
                                       "Loose wiring connections"
                                       "Power available but poor connections prevent operation"
                                       "Loose wire connections observed")
                else (assert (diagnosis 
                        (appliance-type fan)
                        (problem "Motor failure")
                        (confidence 0.7)
                        (solution "Replace fan motor or capacitor")
                        (cost-estimate 80.0)
                        (urgency high)))
                     (record-explanation "fan-no-power-diagnosis"
                                       "Motor failure"
                                       "Power and connections OK but fan won't start"
                                       "Motor or capacitor likely failed"))))

(defrule fan-unusual-noise-diagnosis
    (appliance (type fan))
    (symptom (appliance-type fan) (name unusual-noise) (observed yes))
    =>
    (if (eq (ask-user "Is the noise a grinding or scraping sound?") yes)
        then (assert (diagnosis 
                (appliance-type fan)
                (problem "Worn bearings")
                (confidence 0.85)
                (solution "Replace motor bearings or entire motor")
                (cost-estimate 60.0)
                (urgency medium)))
             (record-explanation "fan-unusual-noise-diagnosis"
                               "Worn bearings"
                               "Grinding noise indicates mechanical wear in bearings"
                               "Grinding/scraping sound reported")
        else (if (eq (ask-user "Does the noise sound like rattling or clicking?") yes)
                then (assert (diagnosis 
                        (appliance-type fan)
                        (problem "Loose blade or hardware")
                        (confidence 0.9)
                        (solution "Tighten fan blades and mounting hardware")
                        (cost-estimate 10.0)
                        (urgency low)))
                     (record-explanation "fan-unusual-noise-diagnosis"
                                       "Loose blade or hardware"
                                       "Rattling indicates loose mechanical components"
                                       "Rattling/clicking sound reported"))))

(defrule fan-slow-running-diagnosis
    (appliance (type fan))
    (symptom (appliance-type fan) (name slow-running) (observed yes))
    =>
    (bind ?voltage (ask-number "What is the voltage reading at the fan terminals?" 100 250))
    (if (< ?voltage 200)
        then (assert (diagnosis 
                (appliance-type fan)
                (problem "Low voltage supply")
                (confidence 0.8)
                (solution "Check wiring for voltage drop, upgrade electrical supply")
                (cost-estimate 75.0)
                (urgency medium)))
             (record-explanation "fan-slow-running-diagnosis"
                               "Low voltage supply"
                               "Voltage below normal range causes reduced motor speed"
                               (str-cat "Measured voltage: " ?voltage "V (below 200V)"))
        else (assert (diagnosis 
                (appliance-type fan)
                (problem "Failing capacitor")
                (confidence 0.85)
                (solution "Replace start/run capacitor")
                (cost-estimate 25.0)
                (urgency medium)))
             (record-explanation "fan-slow-running-diagnosis"
                               "Failing capacitor"
                               "Normal voltage but slow speed indicates capacitor issues"
                               (str-cat "Voltage normal (" ?voltage "V) but speed reduced"))))

(defrule fan-excessive-vibration-diagnosis
    (appliance (type fan))
    (symptom (appliance-type fan) (name excessive-vibration) (observed yes))
    =>
    (if (eq (ask-user "Are the fan blades visibly bent or damaged?") yes)
        then (assert (diagnosis 
                (appliance-type fan)
                (problem "Damaged fan blades")
                (confidence 0.9)
                (solution "Replace damaged fan blades")
                (cost-estimate 30.0)
                (urgency medium)))
             (record-explanation "fan-excessive-vibration-diagnosis"
                               "Damaged fan blades"
                               "Bent or damaged blades cause imbalance and vibration"
                               "Visible blade damage observed")
        else (assert (diagnosis 
                (appliance-type fan)
                (problem "Unbalanced fan assembly")
                (confidence 0.75)
                (solution "Balance fan blades or replace motor shaft")
                (cost-estimate 40.0)
                (urgency low)))
             (record-explanation "fan-excessive-vibration-diagnosis"
                               "Unbalanced fan assembly"
                               "Vibration without visible damage indicates imbalance"
                               "No visible damage but excessive vibration")))

(defrule fan-overheating-diagnosis
    (appliance (type fan))
    (symptom (appliance-type fan) (name overheating) (observed yes))
    =>
    (bind ?current (ask-number "What is the current draw in amperes?" 0 20))
    (if (> ?current 5)
        then (assert (diagnosis 
                (appliance-type fan)
                (problem "Motor overload")
                (confidence 0.85)
                (solution "Check for obstructions, replace overloaded motor")
                (cost-estimate 90.0)
                (urgency high)))
             (record-explanation "fan-overheating-diagnosis"
                               "Motor overload"
                               "High current draw indicates motor working beyond capacity"
                               (str-cat "Current draw: " ?current "A (above normal 5A)"))
        else (assert (diagnosis 
                (appliance-type fan)
                (problem "Poor ventilation or dust buildup")
                (confidence 0.7)
                (solution "Clean motor vents and lubricate bearings")
                (cost-estimate 15.0)
                (urgency medium)))
             (record-explanation "fan-overheating-diagnosis"
                               "Poor ventilation or dust buildup"
                               "Normal current but overheating suggests cooling issues"
                               (str-cat "Current normal (" ?current "A) but overheating"))))

;; ================================================================
;; WASHING MACHINE DIAGNOSIS RULES
;; ================================================================

(defrule gather-washing-machine-symptoms
    ?gather <- (gather-washing-machine-symptoms)
    =>
    (retract ?gather)
    (printout t crlf "=== WASHING MACHINE DIAGNOSIS ===" crlf)
    
    (if (eq (ask-user "Does the washing machine not start at all?") yes)
        then (assert (symptom (appliance-type washing-machine) (name no-start) (observed yes))))
    
    (if (eq (ask-user "Does the machine fill with water but not agitate or spin?") yes)
        then (assert (symptom (appliance-type washing-machine) (name no-agitation) (observed yes))))
    
    (if (eq (ask-user "Does the machine not drain water properly?") yes)
        then (assert (symptom (appliance-type washing-machine) (name no-drain) (observed yes))))
    
    (if (eq (ask-user "Does the machine make loud noises during operation?") yes)
        then (assert (symptom (appliance-type washing-machine) (name loud-noise) (observed yes))))
    
    (if (eq (ask-user "Does the machine trip the circuit breaker or blow fuses?") yes)
        then (assert (symptom (appliance-type washing-machine) (name electrical-overload) (observed yes))))
    
    (assert (diagnose-washing-machine)))

(defrule washing-machine-no-start-diagnosis
    (appliance (type washing-machine))
    (symptom (appliance-type washing-machine) (name no-start) (observed yes))
    =>
    (if (eq (ask-user "Is there power at the outlet?") no)
        then (assert (diagnosis 
                (appliance-type washing-machine)
                (problem "No electrical power")
                (confidence 0.95)
                (solution "Check circuit breaker, GFCI outlet, or electrical supply")
                (cost-estimate 25.0)
                (urgency high)))
             (record-explanation "washing-machine-no-start-diagnosis"
                               "No electrical power"
                               "No power at outlet prevents any operation"
                               "Power outlet test failed")
        else (if (eq (ask-user "Is the door/lid properly closed and latched?") no)
                then (assert (diagnosis 
                        (appliance-type washing-machine)
                        (problem "Door/lid switch malfunction")
                        (confidence 0.85)
                        (solution "Adjust or replace door/lid safety switch")
                        (cost-estimate 45.0)
                        (urgency medium)))
                     (record-explanation "washing-machine-no-start-diagnosis"
                                       "Door/lid switch malfunction"
                                       "Safety interlocks prevent operation when door/lid not secured"
                                       "Door/lid not properly closed or switch failed")
                else (assert (diagnosis 
                        (appliance-type washing-machine)
                        (problem "Control board or timer failure")
                        (confidence 0.7)
                        (solution "Replace control board or timer assembly")
                        (cost-estimate 150.0)
                        (urgency high)))
                     (record-explanation "washing-machine-no-start-diagnosis"
                                       "Control board or timer failure"
                                       "Power OK and safety switches OK but no start indicates control failure"
                                       "All basic checks passed but machine won't start"))))

(defrule washing-machine-no-agitation-diagnosis
    (appliance (type washing-machine))
    (symptom (appliance-type washing-machine) (name no-agitation) (observed yes))
    =>
    (if (eq (ask-user "Can you hear the motor running?") no)
        then (assert (diagnosis 
                (appliance-type washing-machine)
                (problem "Motor failure")
                (confidence 0.8)
                (solution "Replace wash motor or motor coupling")
                (cost-estimate 200.0)
                (urgency high)))
             (record-explanation "washing-machine-no-agitation-diagnosis"
                               "Motor failure"
                               "No motor sound indicates motor electrical or mechanical failure"
                               "Motor not running - no sound detected")
        else (if (eq (ask-user "Does the motor run but the agitator/drum doesn't move?") yes)
                then (assert (diagnosis 
                        (appliance-type washing-machine)
                        (problem "Broken drive belt or coupling")
                        (confidence 0.9)
                        (solution "Replace drive belt or motor coupling")
                        (cost-estimate 75.0)
                        (urgency medium)))
                     (record-explanation "washing-machine-no-agitation-diagnosis"
                                       "Broken drive belt or coupling"
                                       "Motor running but no mechanical movement indicates drive train failure"
                                       "Motor runs but agitator/drum doesn't move"))))

(defrule washing-machine-no-drain-diagnosis
    (appliance (type washing-machine))
    (symptom (appliance-type washing-machine) (name no-drain) (observed yes))
    =>
    (if (eq (ask-user "Is the drain hose kinked or clogged?") yes)
        then (assert (diagnosis 
                (appliance-type washing-machine)
                (problem "Blocked drain system")
                (confidence 0.85)
                (solution "Clear drain hose and check for clogs")
                (cost-estimate 30.0)
                (urgency medium)))
             (record-explanation "washing-machine-no-drain-diagnosis"
                               "Blocked drain system"
                               "Physical obstruction prevents water drainage"
                               "Drain hose kinked or clogged")
        else (if (eq (ask-user "Can you hear the drain pump running?") no)
                then (assert (diagnosis 
                        (appliance-type washing-machine)
                        (problem "Drain pump failure")
                        (confidence 0.8)
                        (solution "Replace drain pump motor")
                        (cost-estimate 120.0)
                        (urgency high)))
                     (record-explanation "washing-machine-no-drain-diagnosis"
                                       "Drain pump failure"
                                       "No pump sound indicates electrical failure of drain pump"
                                       "Drain pump not running - no sound")
                else (assert (diagnosis 
                        (appliance-type washing-machine)
                        (problem "Pump impeller obstruction")
                        (confidence 0.75)
                        (solution "Remove obstruction from pump impeller")
                        (cost-estimate 50.0)
                        (urgency medium)))
                     (record-explanation "washing-machine-no-drain-diagnosis"
                                       "Pump impeller obstruction"
                                       "Pump runs but doesn't drain indicates mechanical blockage"
                                       "Pump running but not draining water"))))

(defrule washing-machine-loud-noise-diagnosis
    (appliance (type washing-machine))
    (symptom (appliance-type washing-machine) (name loud-noise) (observed yes))
    =>
    (if (eq (ask-user "Does the noise occur during the spin cycle?") yes)
        then (assert (diagnosis 
                (appliance-type washing-machine)
                (problem "Worn drum bearings")
                (confidence 0.8)
                (solution "Replace drum bearings and seals")
                (cost-estimate 180.0)
                (urgency medium)))
             (record-explanation "washing-machine-loud-noise-diagnosis"
                               "Worn drum bearings"
                               "Noise during spin indicates bearing wear from high-speed rotation"
                               "Loud noise during spin cycle")
        else (if (eq (ask-user "Is the machine properly leveled?") no)
                then (assert (diagnosis 
                        (appliance-type washing-machine)
                        (problem "Machine not level")
                        (confidence 0.9)
                        (solution "Level the machine and adjust feet")
                        (cost-estimate 15.0)
                        (urgency low)))
                     (record-explanation "washing-machine-loud-noise-diagnosis"
                                       "Machine not level"
                                       "Unlevel machine causes vibration and noise during operation"
                                       "Machine not properly leveled"))))

(defrule washing-machine-electrical-overload-diagnosis
    (appliance (type washing-machine))
    (symptom (appliance-type washing-machine) (name electrical-overload) (observed yes))
    =>
    (bind ?current (ask-number "What is the current draw in amperes when it trips?" 0 50))
    (if (> ?current 20)
        then (assert (diagnosis 
                (appliance-type washing-machine)
                (problem "Motor short circuit")
                (confidence 0.85)
                (solution "Replace motor windings or entire motor")
                (cost-estimate 250.0)
                (urgency critical)))
             (record-explanation "washing-machine-electrical-overload-diagnosis"
                               "Motor short circuit"
                               "Excessive current draw indicates electrical short in motor"
                               (str-cat "Current draw: " ?current "A (above normal 15A)"))
        else (assert (diagnosis 
                (appliance-type washing-machine)
                (problem "Overloaded circuit or weak breaker")
                (confidence 0.7)
                (solution "Check circuit capacity or replace circuit breaker")
                (cost-estimate 60.0)
                (urgency medium)))
             (record-explanation "washing-machine-electrical-overload-diagnosis"
                               "Overloaded circuit or weak breaker"
                               "Normal current but trips breaker suggests circuit or breaker issues"
                               (str-cat "Current draw normal (" ?current "A) but breaker trips"))))

;; ================================================================
;; TV DIAGNOSIS RULES
;; ================================================================

(defrule gather-tv-symptoms
    ?gather <- (gather-tv-symptoms)
    =>
    (retract ?gather)
    (printout t crlf "=== TV DIAGNOSIS ===" crlf)
    
    (if (eq (ask-user "Does the TV not turn on at all (no power light)?") yes)
        then (assert (symptom (appliance-type tv) (name no-power) (observed yes))))
    
    (if (eq (ask-user "Does the TV turn on but show no picture (black screen)?") yes)
        then (assert (symptom (appliance-type tv) (name no-picture) (observed yes))))
    
    (if (eq (ask-user "Does the TV have picture but no sound?") yes)
        then (assert (symptom (appliance-type tv) (name no-sound) (observed yes))))
    
    (if (eq (ask-user "Does the TV show distorted or flickering picture?") yes)
        then (assert (symptom (appliance-type tv) (name picture-distortion) (observed yes))))
    
    (if (eq (ask-user "Does the TV randomly turn off or restart?") yes)
        then (assert (symptom (appliance-type tv) (name random-shutdown) (observed yes))))
    
    (assert (diagnose-tv)))

(defrule tv-no-power-diagnosis
    (appliance (type tv))
    (symptom (appliance-type tv) (name no-power) (observed yes))
    =>
    (if (eq (ask-user "Is there power at the wall outlet?") no)
        then (assert (diagnosis 
                (appliance-type tv)
                (problem "No AC power supply")
                (confidence 0.95)
                (solution "Check wall outlet, power cord, and circuit breaker")
                (cost-estimate 20.0)
                (urgency high)))
             (record-explanation "tv-no-power-diagnosis"
                               "No AC power supply"
                               "No power at outlet prevents TV from receiving electricity"
                               "Wall outlet power test failed")
        else (if (eq (ask-user "Is the power cord damaged or loose?") yes)
                then (assert (diagnosis 
                        (appliance-type tv)
                        (problem "Faulty power cord")
                        (confidence 0.85)
                        (solution "Replace power cord")
                        (cost-estimate 25.0)
                        (urgency medium)))
                     (record-explanation "tv-no-power-diagnosis"
                                       "Faulty power cord"
                                       "Damaged power cord interrupts electrical connection"
                                       "Power cord damaged or loose connection")
                else (assert (diagnosis 
                        (appliance-type tv)
                        (problem "Internal power supply failure")
                        (confidence 0.8)
                        (solution "Replace internal power supply board")
                        (cost-estimate 120.0)
                        (urgency high)))
                     (record-explanation "tv-no-power-diagnosis"
                                       "Internal power supply failure"
                                       "External power OK but TV won't start indicates internal PSU failure"
                                       "Power available but TV internal circuits not responding"))))

(defrule tv-no-picture-diagnosis
    (appliance (type tv))
    (symptom (appliance-type tv) (name no-picture) (observed yes))
    =>
    (if (eq (ask-user "Can you hear sound from the TV?") yes)
        then (if (eq (ask-user "Is there a faint backlight visible in dark room?") no)
                then (assert (diagnosis 
                        (appliance-type tv)
                        (problem "Backlight failure")
                        (confidence 0.85)
                        (solution "Replace LED backlight strips or inverter")
                        (cost-estimate 150.0)
                        (urgency medium)))
                     (record-explanation "tv-no-picture-diagnosis"
                                       "Backlight failure"
                                       "Sound OK but no backlight indicates LED/inverter failure"
                                       "Audio present but no backlight visible")
                else (assert (diagnosis 
                        (appliance-type tv)
                        (problem "LCD panel or T-Con board failure")
                        (confidence 0.75)
                        (solution "Replace LCD panel or T-Con board")
                        (cost-estimate 200.0)
                        (urgency medium)))
                     (record-explanation "tv-no-picture-diagnosis"
                                       "LCD panel or T-Con board failure"
                                       "Backlight OK but no picture indicates panel or timing control issues"
                                       "Backlight visible but no picture content"))
        else (assert (diagnosis 
                (appliance-type tv)
                (problem "Main board failure")
                (confidence 0.8)
                (solution "Replace main logic board")
                (cost-estimate 180.0)
                (urgency high)))
             (record-explanation "tv-no-picture-diagnosis"
                               "Main board failure"
                               "No picture or sound indicates main processing board failure"
                               "No audio or video output")))

(defrule tv-no-sound-diagnosis
    (appliance (type tv))
    (symptom (appliance-type tv) (name no-sound) (observed yes))
    =>
    (if (eq (ask-user "Is the TV muted or volume turned down?") yes)
        then (assert (diagnosis 
                (appliance-type tv)
                (problem "Audio settings issue")
                (confidence 0.95)
                (solution "Check volume, mute settings, and audio output selection")
                (cost-estimate 0.0)
                (urgency low)))
             (record-explanation "tv-no-sound-diagnosis"
                               "Audio settings issue"
                               "Simple configuration issue with audio controls"
                               "TV muted or volume settings incorrect")
        else (if (eq (ask-user "Do external speakers/headphones work when connected?") yes)
                then (assert (diagnosis 
                        (appliance-type tv)
                        (problem "Internal speaker failure")
                        (confidence 0.8)
                        (solution "Replace internal speakers")
                        (cost-estimate 60.0)
                        (urgency low)))
                     (record-explanation "tv-no-sound-diagnosis"
                                       "Internal speaker failure"
                                       "External audio works indicating internal speaker damage"
                                       "External speakers work but internal speakers don't")
                else (assert (diagnosis 
                        (appliance-type tv)
                        (problem "Audio processing circuit failure")
                        (confidence 0.75)
                        (solution "Replace audio processing board or main board")
                        (cost-estimate 140.0)
                        (urgency medium)))
                     (record-explanation "tv-no-sound-diagnosis"
                                       "Audio processing circuit failure"
                                       "No audio on any output indicates audio circuit failure"
                                       "No audio output on any connection"))))

(defrule tv-picture-distortion-diagnosis
    (appliance (type tv))
    (symptom (appliance-type tv) (name picture-distortion) (observed yes))
    =>
    (if (eq (ask-user "Are there horizontal or vertical lines on the screen?") yes)
        then (assert (diagnosis 
                (appliance-type tv)
                (problem "T-Con board or ribbon cable failure")
                (confidence 0.8)
                (solution "Replace T-Con board or reseat ribbon cables")
                (cost-estimate 100.0)
                (urgency medium)))
             (record-explanation "tv-picture-distortion-diagnosis"
                               "T-Con board or ribbon cable failure"
                               "Line artifacts indicate timing control or connection issues"
                               "Horizontal or vertical lines visible on screen")
        else (if (eq (ask-user "Does the picture flicker or have color issues?") yes)
                then (assert (diagnosis 
                        (appliance-type tv)
                        (problem "Video processing or cable connection issue")
                        (confidence 0.7)
                        (solution "Check input cables or replace video processing circuits")
                        (cost-estimate 80.0)
                        (urgency low)))
                     (record-explanation "tv-picture-distortion-diagnosis"
                                       "Video processing or cable connection issue"
                                       "Flickering and color issues suggest signal processing problems"
                                       "Picture flickers or has color distortion"))))

(defrule tv-random-shutdown-diagnosis
    (appliance (type tv))
    (symptom (appliance-type tv) (name random-shutdown) (observed yes))
    =>
    (if (eq (ask-user "Does the TV feel hot to the touch?") yes)
        then (assert (diagnosis 
                (appliance-type tv)
                (problem "Overheating protection activation")
                (confidence 0.85)
                (solution "Clean vents, replace cooling fan, or repair thermal protection")
                (cost-estimate 70.0)
                (urgency medium)))
             (record-explanation "tv-random-shutdown-diagnosis"
                               "Overheating protection activation"
                               "Excessive heat triggers safety shutdown circuits"
                               "TV feels hot and shuts down randomly")
        else (if (eq (ask-user "Does it happen during specific scenes or bright images?") yes)
                then (assert (diagnosis 
                        (appliance-type tv)
                        (problem "Power supply insufficient capacity")
                        (confidence 0.75)
                        (solution "Replace power supply with higher capacity unit")
                        (cost-estimate 130.0)
                        (urgency medium)))
                     (record-explanation "tv-random-shutdown-diagnosis"
                                       "Power supply insufficient capacity"
                                       "Shutdown during high-demand scenes indicates power supply inadequacy"
                                       "Shutdowns occur during bright scenes or high power demand")
                else (assert (diagnosis 
                        (appliance-type tv)
                        (problem "Main board or firmware issue")
                        (confidence 0.7)
                        (solution "Update firmware or replace main board")
                        (cost-estimate 160.0)
                        (urgency medium)))
                     (record-explanation "tv-random-shutdown-diagnosis"
                                       "Main board or firmware issue"
                                       "Random shutdowns without pattern suggest control system failure"
                                       "Random shutdowns with no apparent pattern"))))

;; ================================================================
;; BACKWARD CHAINING RULES
;; ================================================================

(defrule start-backward-chaining
    (backward-chain ?appliance)
    =>
    (enable-backward-chaining)
    (switch ?appliance
        (case fan then
            (assert (hypothesis (appliance-type fan) (problem "Power supply failure") (status active) (confidence 0.0) (evidence-required "no-power-symptoms")))
            (assert (hypothesis (appliance-type fan) (problem "Motor failure") (status active) (confidence 0.0) (evidence-required "mechanical-symptoms")))
            (assert (hypothesis (appliance-type fan) (problem "Electrical overload") (status active) (confidence 0.0) (evidence-required "overload-symptoms"))))
        (case washing-machine then
            (assert (hypothesis (appliance-type washing-machine) (problem "Control board failure") (status active) (confidence 0.0) (evidence-required "electronic-symptoms")))
            (assert (hypothesis (appliance-type washing-machine) (problem "Motor failure") (status active) (confidence 0.0) (evidence-required "mechanical-symptoms")))
            (assert (hypothesis (appliance-type washing-machine) (problem "Electrical supply issue") (status active) (confidence 0.0) (evidence-required "power-symptoms"))))
        (case tv then
            (assert (hypothesis (appliance-type tv) (problem "Power supply failure") (status active) (confidence 0.0) (evidence-required "power-symptoms")))
            (assert (hypothesis (appliance-type tv) (problem "Display failure") (status active) (confidence 0.0) (evidence-required "display-symptoms")))
            (assert (hypothesis (appliance-type tv) (problem "Audio circuit failure") (status active) (confidence 0.0) (evidence-required "audio-symptoms")))))
    (assert (test-hypotheses ?appliance)))

(defrule test-power-supply-hypothesis
    ?h <- (hypothesis (appliance-type ?type) (problem "Power supply failure") (status active))
    (test-hypotheses ?type)
    =>
    (printout t crlf "=== TESTING HYPOTHESIS: Power Supply Failure ===" crlf)
    (bind ?voltage-test (ask-user "Is there proper voltage at the power input?"))
    (bind ?cord-test (ask-user "Is the power cord intact and properly connected?"))
    (bind ?outlet-test (ask-user "Does the outlet provide power to other devices?"))
    
    (bind ?confidence 0.0)
    (if (eq ?voltage-test no) then (bind ?confidence (+ ?confidence 0.4)))
    (if (eq ?cord-test no) then (bind ?confidence (+ ?confidence 0.3)))
    (if (eq ?outlet-test no) then (bind ?confidence (+ ?confidence 0.3)))
    
    (if (> ?confidence 0.5)
        then (modify ?h (status proven) (confidence ?confidence))
             (assert (diagnosis (appliance-type ?type) (problem "Power supply failure") 
                               (confidence ?confidence) (solution "Check power supply, cord, and outlet")
                               (cost-estimate 50.0) (urgency high)))
             (record-explanation "backward-chaining-power"
                               "Power supply failure"
                               "Hypothesis proven through systematic testing"
                               (str-cat "Voltage test: " ?voltage-test ", Cord test: " ?cord-test ", Outlet test: " ?outlet-test))
        else (modify ?h (status disproven) (confidence ?confidence))))

(defrule test-motor-failure-hypothesis
    ?h <- (hypothesis (appliance-type ?type) (problem "Motor failure") (status active))
    (test-hypotheses ?type)
    =>
    (printout t crlf "=== TESTING HYPOTHESIS: Motor Failure ===" crlf)
    (bind ?motor-sound (ask-user "Can you hear the motor attempting to run?"))
    (bind ?motor-heat (ask-user "Does the motor get excessively hot?"))
    (bind ?movement (ask-user "Is there any mechanical movement when powered?"))
    
    (bind ?confidence 0.0)
    (if (eq ?motor-sound no) then (bind ?confidence (+ ?confidence 0.4)))
    (if (eq ?motor-heat yes) then (bind ?confidence (+ ?confidence 0.3)))
    (if (eq ?movement no) then (bind ?confidence (+ ?confidence 0.3)))
    
    (if (> ?confidence 0.5)
        then (modify ?h (status proven) (confidence ?confidence))
             (assert (diagnosis (appliance-type ?type) (problem "Motor failure")
                               (confidence ?confidence) (solution "Replace motor or motor components")
                               (cost-estimate 120.0) (urgency high)))
             (record-explanation "backward-chaining-motor"
                               "Motor failure"
                               "Hypothesis proven through motor-specific testing"
                               (str-cat "Motor sound: " ?motor-sound ", Heat: " ?motor-heat ", Movement: " ?movement))
        else (modify ?h (status disproven) (confidence ?confidence))))

(defrule test-display-failure-hypothesis
    ?h <- (hypothesis (appliance-type tv) (problem "Display failure") (status active))
    (test-hypotheses tv)
    =>
    (printout t crlf "=== TESTING HYPOTHESIS: Display Failure ===" crlf)
    (bind ?backlight (ask-user "Is there any backlight visible in a dark room?"))
    (bind ?menu-display (ask-user "Can you access on-screen menus?"))
    (bind ?external-input (ask-user "Do external inputs (HDMI, etc.) work?"))
    
    (bind ?confidence 0.0)
    (if (eq ?backlight no) then (bind ?confidence (+ ?confidence 0.4)))
    (if (eq ?menu-display no) then (bind ?confidence (+ ?confidence 0.3)))
    (if (eq ?external-input no) then (bind ?confidence (+ ?confidence 0.3)))
    
    (if (> ?confidence 0.5)
        then (modify ?h (status proven) (confidence ?confidence))
             (assert (diagnosis (appliance-type tv) (problem "Display failure")
                               (confidence ?confidence) (solution "Replace display panel or backlight system")
                               (cost-estimate 200.0) (urgency medium)))
             (record-explanation "backward-chaining-display"
                               "Display failure"
                               "Hypothesis proven through display-specific testing"
                               (str-cat "Backlight: " ?backlight ", Menu: " ?menu-display ", External: " ?external-input))
        else (modify ?h (status disproven) (confidence ?confidence))))

(defrule summarize-backward-chaining
    (test-hypotheses ?type)
    (not (hypothesis (appliance-type ?type) (status active)))
    =>
    (printout t crlf "=== BACKWARD CHAINING RESULTS ===" crlf)
    (printout t "Hypotheses tested for " ?type ":" crlf)
    
    (do-for-all-facts ((?h hypothesis)) 
        (and (eq ?h:appliance-type ?type) (eq ?h:status proven))
        (printout t "PROVEN: " ?h:problem " (Confidence: " (* ?h:confidence 100) "%)" crlf))
    
    (do-for-all-facts ((?h hypothesis))
        (and (eq ?h:appliance-type ?type) (eq ?h:status disproven))
        (printout t "DISPROVEN: " ?h:problem " (Confidence: " (* ?h:confidence 100) "%)" crlf))
        
    (printout t "Backward chaining analysis complete." crlf))

(defrule enable-backward-chaining-mode
    (command backward-chain ?appliance)
    =>
    (printout t crlf "Starting backward chaining analysis for " ?appliance "..." crlf)
    (assert (backward-chain ?appliance)))

;; ================================================================
;; EXPLANATION SYSTEM RULES
;; ================================================================

(defrule handle-why-question
    (question (text "why") (appliance-type ?type))
    (diagnosis (appliance-type ?type) (problem ?problem))
    (explanation (conclusion ?problem) (reasoning ?reasoning) (evidence ?evidence))
    =>
    (printout t crlf "=== WHY EXPLANATION ===" crlf)
    (printout t "Question: Why was this diagnosis made?" crlf)
    (printout t "Diagnosis: " ?problem crlf)
    (printout t "Reasoning: " ?reasoning crlf)
    (printout t "Evidence: " ?evidence crlf)
    (printout t crlf "Reasoning Chain:" crlf)
    (printout t "1. Observed symptoms triggered diagnostic rules" crlf)
    (printout t "2. Evidence was collected through targeted questions" crlf)
    (printout t "3. Confidence calculated based on evidence strength" crlf)
    (printout t "4. Conclusion reached through " 
              (if ?*bc-mode* then "backward chaining" else "forward chaining") " inference" crlf))

(defrule handle-how-question
    (question (text "how") (appliance-type ?type))
    (diagnosis (appliance-type ?type) (problem ?problem) (solution ?solution))
    =>
    (printout t crlf "=== HOW EXPLANATION ===" crlf)
    (printout t "Question: How to fix this problem?" crlf)
    (printout t "Problem: " ?problem crlf)
    (printout t "Solution: " ?solution crlf)
    (printout t "This solution addresses the root cause identified through systematic diagnosis." crlf)
    (printout t crlf "Diagnostic Method: " 
              (if ?*bc-mode* then "Hypothesis testing (backward chaining)" else "Symptom analysis (forward chaining)") crlf))

(defrule handle-chain-question
    (question (text "chain") (appliance-type ?type))
    =>
    (printout t crlf "=== REASONING CHAIN ===" crlf)
    (printout t "Complete diagnostic reasoning chain:" crlf crlf)
    
    (do-for-all-facts ((?e explanation) (?d diagnosis))
        (and (eq ?d:appliance-type ?type) (eq ?e:conclusion ?d:problem))
        (printout t "Rule: " ?e:rule-name crlf)
        (printout t "Conclusion: " ?e:conclusion crlf)
        (printout t "Reasoning: " ?e:reasoning crlf)
        (printout t "Evidence: " ?e:evidence crlf)
        (printout t "----------------------------------------" crlf)))

;; ================================================================
;; FINAL RESULTS AND SUMMARY RULES
;; ================================================================

(defrule display-diagnosis-results
    (or (diagnose-fan) (diagnose-washing-machine) (diagnose-tv))
    (diagnosis (appliance-type ?type) (problem ?problem) (confidence ?conf) 
               (solution ?solution) (cost-estimate ?cost) (urgency ?urgency))
    =>
    (printout t crlf "=========================================" crlf)
    (printout t "DIAGNOSIS RESULTS" crlf)
    (printout t "=========================================" crlf)
    (printout t "Appliance: " (upcase ?type) crlf)
    (printout t "Problem Identified: " ?problem crlf)
    (printout t "Confidence Level: " (* ?conf 100) "%" crlf)
    (printout t "Recommended Solution: " ?solution crlf)
    (printout t "Estimated Cost: $" ?cost crlf)
    (printout t "Urgency Level: " (upcase ?urgency) crlf)
    (printout t crlf "For explanations, you can ask:" crlf)
    (printout t "- 'Why' - to understand the reasoning" crlf)
    (printout t "- 'How' - to get detailed repair steps" crlf)
    (printout t "- 'Chain' - to see complete reasoning chain" crlf)
    (printout t "- 'Backward-chain [appliance]' - for hypothesis testing" crlf)
    (printout t "=========================================" crlf)
    (assert (question (text "interaction") (appliance-type ?type) (asked no))))

(defrule handle-user-interaction
    ?interact <- (question (text "interaction") (appliance-type ?type) (asked no))
    =>
    (modify ?interact (asked yes))
    (printout t crlf "Enter 'why', 'how', 'chain', 'backward-chain [appliance]', or 'exit': ")
    (bind ?response (read))
    (switch ?response
        (case why then (assert (question (text "why") (appliance-type ?type))))
        (case how then (assert (question (text "how") (appliance-type ?type))))
        (case chain then (assert (question (text "chain") (appliance-type ?type))))
        (case backward-chain then 
            (printout t "Enter appliance type (fan/washing-machine/tv): ")
            (bind ?appliance (read))
            (assert (command backward-chain ?appliance)))
        (case exit then (printout t "Thank you for using the Electrical Diagnosis System!" crlf))
        (default (printout t "Please enter 'why', 'how', 'chain', 'backward-chain [appliance]', or 'exit'" crlf)
                (assert (question (text "interaction") (appliance-type ?type) (asked no))))))

;; ================================================================
;; SYSTEM INITIALIZATION
;; ================================================================

(printout t "System loaded. Type (run) to start diagnosis." crlf)
(printout t "Advanced Features:" crlf)
(printout t "- Forward Chaining: Standard symptom-driven diagnosis" crlf) 
(printout t "- Backward Chaining: Use 'backward-chain [appliance]' for hypothesis testing" crlf)
(printout t "- Explanation System: Ask 'why', 'how', or 'chain' questions" crlf)