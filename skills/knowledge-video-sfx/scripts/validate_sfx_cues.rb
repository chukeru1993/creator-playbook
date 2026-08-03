#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "yaml"
require "date"

OPTIONS = {}
OptionParser.new do |parser|
  parser.banner = "Usage: validate_sfx_cues.rb --catalog CATALOG --cues CUES"
  parser.on("--catalog PATH", "Shared sfx-catalog.yaml") { |value| OPTIONS[:catalog] = value }
  parser.on("--cues PATH", "Project sfx-cues.yaml") { |value| OPTIONS[:cues] = value }
end.parse!

abort "Missing --catalog" unless OPTIONS[:catalog]
abort "Missing --cues" unless OPTIONS[:cues]

def load_yaml(path)
  YAML.safe_load(File.read(path), permitted_classes: [Date], aliases: false)
rescue Errno::ENOENT
  abort "File not found: #{path}"
rescue Psych::SyntaxError => error
  abort "Invalid YAML in #{path}: #{error.message.lines.first.strip}"
end

def numeric?(value)
  value.is_a?(Numeric) && value.finite?
end

def add_issue(collection, prefix, message)
  collection << "#{prefix}: #{message}"
end

def valid_range?(value, minimum: 0, maximum: nil)
  value.is_a?(Array) && value.length == 2 && value.all? { |item| numeric?(item) } &&
    value[0] >= minimum && value[0] <= value[1] && (maximum.nil? || value[1] <= maximum)
end

catalog = load_yaml(OPTIONS[:catalog])
cues_document = load_yaml(OPTIONS[:cues])
abort "Catalog must contain assets" unless catalog.is_a?(Hash) && catalog["assets"].is_a?(Array)
abort "Cue file must be a YAML mapping" unless cues_document.is_a?(Hash)

assets = catalog["assets"].each_with_object({}) do |asset, by_id|
  by_id[asset["id"]] = asset if asset.is_a?(Hash) && asset["id"].is_a?(String)
end

errors = []
warnings = []
project = cues_document["project"]
add_issue(errors, "project", "must be a mapping") unless project.is_a?(Hash)
sound_style = nil
if project.is_a?(Hash)
  add_issue(errors, "project.id", "must be a non-empty string") unless project["id"].is_a?(String) && !project["id"].empty?
  add_issue(errors, "project.catalog", "must be a non-empty string") unless project["catalog"].is_a?(String) && !project["catalog"].empty?
  authority = project["timing_authority"]
  allowed_authorities = %w[final_audio_or_srt scene_timeline script_anchors]
  add_issue(errors, "project.timing_authority", "must be one of #{allowed_authorities.join(', ')}") unless allowed_authorities.include?(authority)
  sound_style = project["sound_style"]
  allowed_sound_styles = %w[general_knowledge developer_ui_feedback]
  unless sound_style.nil? || allowed_sound_styles.include?(sound_style)
    add_issue(errors, "project.sound_style", "must be one of #{allowed_sound_styles.join(', ')} when present")
  end
end
developer_ui_feedback = sound_style == "developer_ui_feedback"

add_issue(errors, "schema_version", "must be 1") unless cues_document["schema_version"] == 1
cues = cues_document["cues"]
add_issue(errors, "cues", "must be an array") unless cues.is_a?(Array)
cues ||= []

density_plan = cues_document["density_plan"]
if density_plan.nil?
  add_issue(warnings, "density_plan", "is missing; add a profile and target range before creating a new Spotting plan")
elsif !density_plan.is_a?(Hash)
  add_issue(errors, "density_plan", "must be a mapping")
end

allowed_functions = %w[orientation causality commitment caution resolution emphasis transition]
allowed_priorities = %w[primary supporting optional]
allowed_statuses = %w[needs_audition approved omitted blocked]
allowed_triggers = %w[onset impact settle]
feedback_kind_functions = {
  "execution_start" => %w[orientation transition],
  "result_ready" => %w[resolution commitment],
  "rule_highlight" => %w[emphasis commitment],
  "error_warning" => %w[caution],
  "state_connect" => %w[causality],
  "state_lock" => %w[commitment resolution],
  "section_transition" => %w[transition]
}.freeze
seen_ids = {}

cues.each_with_index do |cue, index|
  prefix = "cues[#{index}]"
  unless cue.is_a?(Hash)
    add_issue(errors, prefix, "must be a mapping")
    next
  end

  cue_id = cue["id"]
  if !cue_id.is_a?(String) || cue_id.empty?
    add_issue(errors, "#{prefix}.id", "must be a non-empty string")
  elsif seen_ids[cue_id]
    add_issue(errors, "#{prefix}.id", "duplicates #{cue_id}")
  else
    seen_ids[cue_id] = true
  end

  %w[scene_id event rationale].each do |key|
    add_issue(errors, "#{prefix}.#{key}", "must be a non-empty string") unless cue[key].is_a?(String) && !cue[key].empty?
  end

  add_issue(errors, "#{prefix}.function", "must be one of #{allowed_functions.join(', ')}") unless allowed_functions.include?(cue["function"])
  add_issue(errors, "#{prefix}.priority", "must be one of #{allowed_priorities.join(', ')}") unless allowed_priorities.include?(cue["priority"])
  status = cue["status"]
  add_issue(errors, "#{prefix}.status", "must be one of #{allowed_statuses.join(', ')}") unless allowed_statuses.include?(status)

  state_change = cue["state_change"]
  if developer_ui_feedback && status != "omitted" && !state_change.is_a?(Hash)
    add_issue(errors, "#{prefix}.state_change", "is required for non-omitted cues in developer_ui_feedback mode")
  end
  if state_change.is_a?(Hash)
    before = state_change["before"]
    after = state_change["after"]
    feedback_kind = state_change["feedback_kind"]
    add_issue(errors, "#{prefix}.state_change.before", "must be a non-empty string") unless before.is_a?(String) && !before.strip.empty?
    add_issue(errors, "#{prefix}.state_change.after", "must be a non-empty string") unless after.is_a?(String) && !after.strip.empty?
    if before.is_a?(String) && after.is_a?(String) && before.strip == after.strip
      add_issue(errors, "#{prefix}.state_change", "before and after must describe different states")
    end
    unless feedback_kind_functions.key?(feedback_kind)
      add_issue(errors, "#{prefix}.state_change.feedback_kind", "must be one of #{feedback_kind_functions.keys.join(', ')}")
    end
    allowed_for_kind = feedback_kind_functions[feedback_kind]
    if allowed_for_kind && !allowed_for_kind.include?(cue["function"])
      add_issue(errors, "#{prefix}.function", "must be one of #{allowed_for_kind.join(', ')} for feedback_kind #{feedback_kind}")
    end
  elsif !state_change.nil?
    add_issue(errors, "#{prefix}.state_change", "must be a mapping or null")
  end

  visual = cue["visual_anchor"]
  unless visual.is_a?(Hash) && visual["action"].is_a?(String) && !visual["action"].empty?
    add_issue(errors, "#{prefix}.visual_anchor", "must include a non-empty action")
  end
  if visual.is_a?(Hash) && !allowed_triggers.include?(visual["trigger"])
    add_issue(errors, "#{prefix}.visual_anchor.trigger", "must be one of #{allowed_triggers.join(', ')}")
  end

  narration = cue["narration_anchor"]
  unless narration.is_a?(Hash) && narration["text"].is_a?(String) && !narration["text"].empty?
    add_issue(errors, "#{prefix}.narration_anchor", "must include the spoken meaning that justifies the cue")
  end

  timing = cue["timing"]
  unless timing.is_a?(Hash)
    add_issue(errors, "#{prefix}.timing", "must be a mapping")
  else
    at_s = timing["at_s"]
    add_issue(errors, "#{prefix}.timing.at_s", "must be a number or null") unless at_s.nil? || numeric?(at_s)
    if project.is_a?(Hash) && project["timing_authority"] == "final_audio_or_srt" && !%w[omitted blocked].include?(status) && !numeric?(at_s)
      add_issue(errors, "#{prefix}.timing.at_s", "is required when timing_authority is final_audio_or_srt")
    end
    add_issue(errors, "#{prefix}.timing.offset_ms", "must be numeric") unless numeric?(timing["offset_ms"])
  end

  target = cue["target"]
  unless target.is_a?(Hash)
    add_issue(errors, "#{prefix}.target", "must be a mapping")
  else
    %w[energy brightness].each do |key|
      range = target[key]
      valid_range = range.is_a?(Array) && range.length == 2 && range.all? { |value| numeric?(value) && value.between?(0, 1) } && range[0] <= range[1]
      add_issue(errors, "#{prefix}.target.#{key}", "must be an ascending [0..1, 0..1] range") unless valid_range
    end
    add_issue(errors, "#{prefix}.target.max_duration_ms", "must be a positive number") unless numeric?(target["max_duration_ms"]) && target["max_duration_ms"].positive?
    if developer_ui_feedback && numeric?(target["max_duration_ms"])
      feedback_kind = state_change.is_a?(Hash) ? state_change["feedback_kind"] : nil
      maximum_duration = feedback_kind == "section_transition" ? 1000 : 800
      if target["max_duration_ms"] > maximum_duration
        add_issue(errors, "#{prefix}.target.max_duration_ms", "must be no greater than #{maximum_duration} in developer_ui_feedback mode")
      end
    end
  end

  candidates = cue["candidates"]
  if !status.eql?("omitted") && !status.eql?("blocked") && (!candidates.is_a?(Array) || candidates.empty?)
    add_issue(errors, "#{prefix}.candidates", "must contain at least one candidate")
  end
  candidate_ids = []
  Array(candidates).each_with_index do |candidate, candidate_index|
    candidate_prefix = "#{prefix}.candidates[#{candidate_index}]"
    unless candidate.is_a?(Hash)
      add_issue(errors, candidate_prefix, "must be a mapping")
      next
    end
    asset_id = candidate["asset_id"]
    asset = assets[asset_id]
    if asset.nil?
      add_issue(errors, "#{candidate_prefix}.asset_id", "does not exist in catalog: #{asset_id.inspect}")
      next
    end
    candidate_ids << asset_id
    add_issue(errors, candidate_prefix, "cannot use asset with status #{asset['status']}") if %w[duplicate review_required].include?(asset["status"])
    add_issue(warnings, candidate_prefix, "uses sparing asset #{asset_id}") if asset["status"] == "sparing"
    if Array(asset["avoid_for"]).include?(cue["event"])
      add_issue(errors, candidate_prefix, "#{asset_id} declares avoid_for #{cue['event']}")
    end
    unless Array(asset["use_for"]).include?(cue["event"])
      add_issue(warnings, candidate_prefix, "#{asset_id} does not declare use_for #{cue['event']}")
    end
    if developer_ui_feedback && target.is_a?(Hash) && numeric?(target["max_duration_ms"]) && numeric?(asset["duration_ms"]) && asset["duration_ms"] > target["max_duration_ms"]
      add_issue(errors, candidate_prefix, "#{asset_id} is #{asset['duration_ms']} ms, exceeding target.max_duration_ms #{target['max_duration_ms']}")
    end
    add_issue(errors, "#{candidate_prefix}.rank", "must be a positive number") unless numeric?(candidate["rank"]) && candidate["rank"].positive?
  end

  selected = cue["selected"]
  if status == "approved" && !selected.is_a?(Hash)
    add_issue(errors, "#{prefix}.selected", "is required for approved cues")
  end
  if selected.is_a?(Hash)
    selected_id = selected["asset_id"]
    asset = assets[selected_id]
    add_issue(errors, "#{prefix}.selected.asset_id", "must be one of the candidates") unless candidate_ids.include?(selected_id)
    add_issue(errors, "#{prefix}.selected.asset_id", "does not exist in catalog") if asset.nil?
    add_issue(errors, "#{prefix}.selected.asset_id", "cannot use asset with status #{asset['status']}") if asset && %w[duplicate review_required].include?(asset["status"])
    gain = selected["gain"]
    add_issue(errors, "#{prefix}.selected.gain", "must be a number from 0 to 1") unless numeric?(gain) && gain.between?(0, 1)
    if developer_ui_feedback && numeric?(gain) && gain > 0.35
      add_issue(warnings, "#{prefix}.selected.gain", "is above the 0.35 UI-feedback starting point; verify it does not mask narration")
    end
  elsif !selected.nil?
    add_issue(errors, "#{prefix}.selected", "must be a mapping or null")
  end
end

if density_plan.is_a?(Hash)
  allowed_profiles = %w[sparse balanced dense]
  profile = density_plan["profile"]
  add_issue(errors, "density_plan.profile", "must be one of #{allowed_profiles.join(', ')}") unless allowed_profiles.include?(profile)

  target_rate = density_plan["target_cues_per_min"]
  add_issue(errors, "density_plan.target_cues_per_min", "must be an ascending positive range no greater than 8") unless valid_range?(target_rate, minimum: 0.1, maximum: 8)

  duration_s = density_plan["duration_s"]
  add_issue(errors, "density_plan.duration_s", "must be a positive number or null") unless duration_s.nil? || (numeric?(duration_s) && duration_s.positive?)

  planned_count = density_plan["planned_cue_count"]
  add_issue(errors, "density_plan.planned_cue_count", "must be a non-negative integer") unless planned_count.is_a?(Integer) && planned_count >= 0

  target_count = density_plan["target_count"]
  unless target_count.nil? || (valid_range?(target_count, minimum: 0) && target_count.all? { |value| value.is_a?(Integer) })
    add_issue(errors, "density_plan.target_count", "must be null or an ascending integer range")
  end

  planned_rate = density_plan["planned_cues_per_min"]
  add_issue(errors, "density_plan.planned_cues_per_min", "must be a non-negative number or null") unless planned_rate.nil? || (numeric?(planned_rate) && planned_rate >= 0)

  uncovered_gap = density_plan["max_uncovered_semantic_gap_s"]
  add_issue(errors, "density_plan.max_uncovered_semantic_gap_s", "must be a non-negative number or null") unless uncovered_gap.nil? || (numeric?(uncovered_gap) && uncovered_gap >= 0)

  active_cues = cues.count { |cue| cue.is_a?(Hash) && %w[needs_audition approved].include?(cue["status"]) }
  if planned_count.is_a?(Integer) && planned_count != active_cues
    add_issue(errors, "density_plan.planned_cue_count", "is #{planned_count}, but #{active_cues} cue(s) are needs_audition or approved")
  end

  if numeric?(duration_s) && duration_s.positive? && valid_range?(target_rate, minimum: 0.1, maximum: 8)
    actual_rate = active_cues * 60.0 / duration_s
    if actual_rate < target_rate[0] - 0.01 || actual_rate > target_rate[1] + 0.01
      add_issue(errors, "density_plan", format("actual density %.2f cue/min is outside target %.2f–%.2f", actual_rate, target_rate[0], target_rate[1]))
    end
    if numeric?(planned_rate) && (planned_rate - actual_rate).abs > 0.05
      add_issue(errors, "density_plan.planned_cues_per_min", format("is %.2f, but actual density is %.2f", planned_rate, actual_rate))
    end
    if target_count.is_a?(Array) && (active_cues < target_count[0] || active_cues > target_count[1])
      add_issue(errors, "density_plan.target_count", "does not contain the actual planned cue count #{active_cues}")
    end
  elsif !duration_s.nil?
    add_issue(errors, "density_plan.duration_s", "must be valid before density can be checked")
  end
end

errors.each { |message| warn "ERROR #{message}" }
warnings.each { |message| warn "WARNING #{message}" }
puts "Validated #{cues.length} cue(s), #{errors.length} error(s), #{warnings.length} warning(s)."
exit(errors.empty? ? 0 : 1)
