<script>
    import {validate, endpoints, getPostFetchOptions} from "$lib/index.js"
    let name;
    let description;
    let minReps;
    let maxReps;
    let minSets;
    let maxSets;
    let minWeight;
    let weightStep;

    async function SaveExercisePlan() {
        let elements = Array.from(document.querySelectorAll('.validate'));
        if(validate(elements).length > 0)
            return alert("Compilare correttamete tutti i campi")

        const data = {
            name,
            description,
            minReps,
            maxReps,
            minSets,
            maxSets,
            minWeight,
            weightStep
        }

        try {
            await fetch(endpoints.insert_plan, getPostFetchOptions(data))
        }catch(e){
            alert("Errore nell'inserimento")
        }

    }
</script>

<div id="container">
    <h3>Insert Exercise Plan</h3>
    <input 
        type="text" 
        name="name" 
        placeholder="Name" 
        class = "validate"

        bind:value={name} 
    >
    <br>
    <textarea 
        name="description" 
        placeholder="Description" 

        bind:value={description}
    ></textarea>
    <br>
    <input 
        type="number" 
        name="minReps" 
        placeholder="Min Reps" 
        class = "validate"

        min = 1
        bind:value={minReps}
    >
    <br>
    <input 
        type="number" 
        name="maxReps" 
        placeholder="Max Reps" 

        min = 1
        bind:value={maxReps}
    >
    <br>
    <input 
        type="number" 
        name="minSets" 
        placeholder="Min Sets" 

        min = 1
        bind:value={minSets}
    >
    <br>
    <input 
        type="number" 
        name="maxSets" 
        placeholder="Max Sets" 

        min = 1
        bind:value={maxSets}
    >
    <br>
    <input 
        type="number" 
        name="minWeight" 
        placeholder="Min Weight" 

        min = 0
        bind:value={minWeight}
    >
    <br>
    <input 
        type="number" 
        name="weightStep" 
        placeholder="Weight Step" 

        min = 0
        bind:value={weightStep}
    >
    <br>
    <button on:click={SaveExercisePlan}>Save</button>
</div>

<style>
    #container {
            text-align: center;
        }

    * {
            margin: 5px;
        }
</style>
