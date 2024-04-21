<script>
    import {validate, endpoints, getPostFetchOptions} from "$lib/index.js"
    export const ExerciseDetail = this
    export let name = "(No Name)"
    export let description = ""
    export let sets = 0
    export let reps = 0
    export let isDone = false
    let repsDone = []
    let note = ""

    async function SaveExecution() {
        let elements = Array.from(document.querySelectorAll('.validate'));
        if(validate(elements).length > 0)
            return alert("Compilare correttamente tutti i campi richiesti")

        const data = {
            name, 
            description,
            sets,
            reps,
        }
        try {
            await fetch(endpoints.insert_execution, getPostFetchOptions(data))
        } catch(e) {
            alert("Errore nel salvataggio")
        }
    }

 </script>
<div id = "exerciseDetail">
    <h2>{name}</h2>
    <br>
    <span id="description">{description}</span>
    <br>
    {#each Array(Number(sets)) as _, i}
        <div id="sets">
            <input 
                bind:value = {repsDone[i]}
                type = "number"
                min = 0
                max = {reps}
                disabled = {isDone}
                placeholder = 0 
                class = "validate"
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
        <button id="save" on:click={SaveExecution}>Fine</button>
    {/if}
</div>

<style>

    #save {
        background-color: #181818;
        color:inherit;
        margin:auto;
        border: 1px;
    }
    #sets {
        font-size: x-large;
    }
    #description {
        font-size: larger;
    }
    #repsInput {
        width: 30px;
        font-size: inherit;
        background-color: inherit;
        border: none;
        border-bottom: 1px solid;
        color:inherit;
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
