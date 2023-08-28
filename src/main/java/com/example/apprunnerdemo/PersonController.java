package com.example.apprunnerdemo;

import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("api/people")
public class PersonController {

    private final PersonService service;

    public PersonController(PersonService service) {
        this.service = service;
    }

    @GetMapping
    public Flux<PersonInfoDTO> getAllPeople() {
        return service.getAllPeople();
    }

    @GetMapping("{id}")
    public Mono<PersonInfoDTO> getPerson(@PathVariable String id, ServerHttpResponse response) {
        response.setStatusCode(HttpStatus.NOT_FOUND);
        return service.getPerson(id).map(x-> {
            response.setStatusCode(HttpStatus.OK);
            return x;
        });
    }


    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    Mono<PersonInfoDTO> createPerson(@RequestBody PersonInfoDTO p) {
        return service.createPerson(p);
    }
}
