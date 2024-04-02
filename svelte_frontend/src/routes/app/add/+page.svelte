<script>
    let name;
    let description;
    let minReps;
    let maxReps;
    let minSets;
    let maxSets;
    let minWeight;
    let weightStep;
    function SaveExercisePlan() {
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

        const path = "/plan/insert"
        fetch(path, { method: "POST", body: JSON.stringify(data) })
    }
</script>


<div id="container">
    <h3>Insert Exercise Plan</h3>
    <input type="text" name="name" placeholder="Name" bind:value={name}>
    <br>
    <textarea name="description" id="" placeholder="Description" bind:value={description}></textarea>
    <br>
    <input type="number" name="minReps" placeholder="Min Reps" bind:value={minReps}>
    <br>
    <input type="number" name="maxReps" placeholder="Max Reps" bind:value={maxReps}>
    <br>
    <input type="number" name="minSets" placeholder="Min Sets" bind:value={minSets}>
    <br>
    <input type="number" name="maxSets" placeholder="Max Sets" bind:value={maxSets}>
    <br>
    <input type="number" name="minWeight" placeholder="Min Weight" bind:value={minWeight}>
    <br>
    <input type="number" name="weightStep" placeholder="Weight Step" bind:value={weightStep}>
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
