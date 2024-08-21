from requests import get
from fitz import open
from os import makedirs as createFolder
from pyhtml2pdf import converter as html2pdf 

def save_problem_to_pdf(url:str,file_name) -> None :
    print(f'saving problem to pdf : {file_name}')
    html2pdf.convert(url,file_name,timeout=3,power=2)


def merge_pdfs(file_name:str,file_list:list[str]) -> None:
    print(f'creating {file_name}')
    result = open()
    for pdf_file in file_list:
        with open(pdf_file) as single_pdf_file:
            result.insert_pdf(single_pdf_file)
    result.save(file_name)

if __name__ == "__main__":
    rating = int(input("rating: "))
    should_resume_from_problem = int(input("resume from a certain problem number ? ( enter -1 for skip) : "))

    # response = get(f"https://c2-ladders-juol.onrender.com/api/ladder?startRating={rating}&endRating={rating+100}")

    createFolder(str(rating),exist_ok=True)

    problems_file_list=list()

    
    response = get('https://codeforces.com/api/problemset.problems')
    data = response.json()


    problem_number  = 1
    if(data['status']=="OK"):


        for result in data['result']['problems']:
            if result['type']=='PROGRAMMING' and 'rating' in result and  int(result['rating'])==rating:
                if(problem_number>100):
                    break

                contest_id=result['contestId']
                index=result['index']
                problem_url=f'https://codeforces.com/problemset/problem/{contest_id}/{index}'

                problem_name=result['name'].lower().replace(' ','_')
                problem_file_name=f'{rating}/{problem_number}_{problem_name}.pdf'

                problem_number+=1
                problems_file_list.append(problem_file_name)

                if(should_resume_from_problem > 0 and problem_number<should_resume_from_problem+1):
                    continue

                save_problem_to_pdf(problem_url,problem_file_name)


    
    merge_pdfs(f'{rating}.pdf',problems_file_list)
