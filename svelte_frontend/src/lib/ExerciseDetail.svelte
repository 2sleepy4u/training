<script>
    export const ExerciseDetail = this
    export let name = "(No Name)"
    export let description = ""
    export let sets = 0
    export let reps = 0
    export let isDone = false
    let repsDone = []
    let note = ""

    async function SaveExecution() {
        const data = {
            name, 
            description,
            sets,
            reps,
        }
        try {
            await fetch("/save_execution", {method: "POST", body: JSON.stringify(data)})
        } catch(e) {}
    }

 </script>
<div id = "exerciseDetail">
    <h2>{name}</h2>
    <br>
    <span>{description}</span>
    <br>
    {#each Array(Number(sets)) as _, i}
        <div>
            <input 
                bind:value={repsDone[i]}
                min = 0
                max = {reps}
                disabled = {isDone}
                placeholder = 0 
                id = "repsInput"
            >
            /{reps}
        </div>
    {/each}
    <br>
    <textarea 
        disabled = {isDone}
        bind:value = {note}
        placeholder = "Note aggiuntive"
    ></textarea>
    <br>
    {#if !isDone}
        <button on:click={SaveExecution}>Fine</button>
    {/if}
</div>

<style>
    #repsInput {
        width: 20px;
    }

    #exerciseDetail {
        text-align: center;
        margin: 5px;
    }

    #exerciseDetail textarea {
        min-height: 100px;
        width: 100%;
    }
    #exerciseDetail button {
        height: 50px;
        width: 50%;

        border-radius: 15px;
    }
</style>
