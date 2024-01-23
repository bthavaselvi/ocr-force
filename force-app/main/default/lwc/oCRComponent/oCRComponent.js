import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/FileUploaderClass.uploadFile'
export default class FileUploaderCompLwc extends LightningElement {
  
    fileData
    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64
            }
            
        }
        reader.readAsDataURL(file)
    }
    
    handleClick(){
        const {base64, filename} = this.fileData
        uploadFile({ base64, filename }).then(result=>{
            this.fileData = null
            let title = `${filename} uploaded successfully!!`
            this.toast(result)
        })
    }

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }
}