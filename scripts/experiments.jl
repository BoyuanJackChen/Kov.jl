using Revise
using Kov
using BSON
using POMDPTools
using Random
using Plots; default(fontfamily="Computer Modern", framestyle=:box)

MODEL_ON_LOCALHOST = false
RUN_BEST = false
RUN_BASELINE = false

# Use command-line arguments instead of manual input
if length(ARGS) < 2
    println("Usage: julia experiments.jl <start_idx> <end_idx>")
    exit(1)
end
start_idx = parse(Int, ARGS[1])
end_idx = parse(Int, ARGS[2])

if @isdefined(surrogate)
    surrogate.params.seed = 0 # reset seed
else
    model_path = expanduser("lmsys/vicuna-7b-v1.5")

    whitebox_params = WhiteBoxParams(; model_path)

    if MODEL_ON_LOCALHOST
        surrogate = WhiteBoxMDP(params=whitebox_params, conv_template=missing)
    else
        surrogate = WhiteBoxMDP(whitebox_params; device_map=nothing)
    end
end

for benchmark_idx in start_idx:end_idx
    @info "Starting iteration $benchmark_idx"
    try
        global mdp, surrogate, whitebox_params, state

        Kov.change_benchmark!(surrogate, benchmark_idx)
        Random.seed!(surrogate.params.seed)

        empty!(surrogate.data)

        @info "Benchmark index $benchmark_idx: $(surrogate.params.prompt)"

        ########################################
        ## Change this for different blackbox models
        ########################################
        params = (name="gpt3-advbench$benchmark_idx", is_aligned=false, target_model=gpt_model("gpt-3.5-turbo-0125"))

        surrogate.params.flipped = params.is_aligned
        prompt = whitebox_params.prompt
        mdp = BlackBoxMDP(params.target_model, surrogate, prompt)  # Initialize MDP
        mdp.flipped = params.is_aligned
        s0 = rand(initialstate(mdp))

        Kov.WhiteBox.clear!()

        if !RUN_BASELINE  # BASELINE here means GCG, etc. 
            policy = solve(mdp.params.solver, mdp)   # Solving MCTS, from POMDPTools
            @time a, info = action_info(policy, s0)
            suffix = select_action(mdp)  # Select the best action (for the last step), from POMDPTools
            printstyled("[BEST ACTION]: $suffix\n", color=:cyan)

            name = string(params.name, "-", params.is_aligned ? "aligned" : "adv")

            data = mdp.data
            BSON.@save "$name-mdp-data.bson" data

            if RUN_BEST
                best_trials = 1
                R_best, data_best = Kov.run_baseline(mdp, best_trials, suffix)  # Only 1 iteration
                mods_best = Kov.compute_moderation(mdp)
                BSON.@save "./results/$(params.name)-best-scores.bson" R_best
                BSON.@save "./results/$(params.name)-best-data.bson" data_best
                BSON.@save "./results/$(params.name)-best-moderation.bson" mods_best
                mod_rate_best = Kov.avg_moderated(mods_best)
                mod_score_best = Kov.avg_moderated_score(mods_best)
                @info "Failed moderation rate (best): $mod_rate_best"
                @info "Average moderation score (best): $mod_score_best"
            end
        else
            R_baseline, data_baseline = run_baseline(mdp, solver.n_iterations)  # 7 iterations by default
            mods_baseline = compute_moderation(mdp)
            BSON.@save "./results/$(params.name)-baseline-scores.bson" R_baseline
            BSON.@save "./results/$(params.name)-baseline-data.bson" data_baseline
            BSON.@save "./results/$(params.name)-baseline-moderation.bson" mods_baseline
            mod_rate_baseline = Kov.avg_moderated(mods_baseline)
            mod_score_baseline = Kov.avg_moderated_score(mods_baseline)
            @info "Failed moderation rate (baseline): $mod_rate_baseline"
            @info "Average moderation score (baseline): $mod_score_baseline"
        end
    catch err
        @error "Error on benchmark $benchmark_idx: $err"
        break
    end
end
