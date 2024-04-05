export const clamp = (val, min, max) => Math.min(Math.max(val, min), max)
export function validate(elements) {
    let notValidElements = []
    for(var el of elements) {
            console.warn(el)
        if(el.min != null && el.type == "number" && Number(el.value) < Number(el.min)) {
            console.error("Min", el)
            notValidElements.push(el)
        } 

        if(el.max != null && el.type == "number" && Number(el.value) > Number(el.max)) {
            console.error("Max", el)
            notValidElements.push(el)
        } 


        if(el.min != null && el.type == "text" && String(el.value).length < Number(el.min)) {
            console.error("Length", el)
            notValidElements.push(el)
        } 
    }

    return notValidElements 
}
export function getPostFetchOptions(data) {
    let result = {
        method: "POST",
        mode: "cors",
        credentials: "include",
    }

    if(data != null)
        result.body = JSON.stringify(data)
    return result

}

const webServer = "http://192.168.1.41"
const port = "8080"
export const endpoints = {
    get_new_session: webServer+port+"/get_new_session",
    insert_execution: webServer+port+"/insert_execution",
    insert_plan: webServer+port+"/insert_plan",
    get_daily: webServer+port+"/get_daily",
    get_history: "",
}
